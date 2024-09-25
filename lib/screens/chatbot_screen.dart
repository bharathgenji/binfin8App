// chatbot_screen.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/claude_service.dart'; // Import the Claude service
import '../services/huggingface_service.dart'; // Import the Hugging Face service

class ChatbotScreen extends StatefulWidget {
  final List<Map<String, dynamic>> assets; // Pass asset list from the dashboard

  const ChatbotScreen({Key? key, required this.assets}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  late ClaudeService _claudeService; // For Anthropic
  late HuggingFaceService _huggingFaceService; // For Hugging Face
  String _selectedModel = 'Anthropic'; // Default selection

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
    _claudeService = ClaudeService(); // Initialize Anthropic Service
    _huggingFaceService = HuggingFaceService(); // Initialize Hugging Face Service
    _addInitialContext(); // Add initial context of assets to chatbot
  }

  // Initialize speech recognition and check permissions
  Future<void> _initializeSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          _stopListening(); // Stop when done or not listening
        }
      },
      onError: (error) {
        print('Speech recognition error: ${error.errorMsg}');
        _showErrorDialog('Speech recognition failed: ${error.errorMsg}');
      },
    );

    if (!available) {
      _showErrorDialog(
          'Failed to initialize speech recognition. Your device may not support this feature.');
    }
  }

  // Add initial context of assets to the conversation
  void _addInitialContext() {
    setState(() {
      _messages.add(ChatMessage(
        text:
            'Hello! I have access to the following assets in your portfolio: Bitcoin, Ethereum, Rare NFT, and USDT. Feel free to ask me questions about these assets.',
        isUser: false,
      ));
    });
  }

  // Start listening to the user's voice and handle the recognized text
  Future<void> _startListening() async {
    if (!_speech.isAvailable) {
      _showErrorDialog('Speech recognition is not available.');
      return;
    }

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          _messages.add(ChatMessage(text: _recognizedText, isUser: true));
        });
        _processRecognizedText(_recognizedText); // Send to selected AI service for response
      },
      listenFor: const Duration(seconds: 10),
      cancelOnError: true,
      partialResults: false,
    );

    setState(() {
      _isListening = true;
    });
  }

  // Stop listening to the user's voice
  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Process the recognized text or user input based on selected AI
  Future<void> _processRecognizedText(String text) async {
    // Prepare the prompt with asset context
    final prompt = 'User has the following assets: Bitcoin, Ethereum, Rare NFT, and USDT. '
        'Respond based on this knowledge. User asked: "$text"';

    String response;

    // Choose AI service based on user selection
    if (_selectedModel == 'Anthropic') {
      response = await _claudeService.sendMessage(prompt);
    } else {
      response = await _huggingFaceService.sendMessage(prompt);
    }

    setState(() {
      _messages.add(ChatMessage(text: response, isUser: false));
    });
  }

  // Send text input to the selected AI service
  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final message = _textController.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
    });
    _processRecognizedText(message);
    _textController.clear(); // Clear the input field
  }

  // Show a dialog for errors
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Build the chatbot UI
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8, // Chatbot window height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildModelSelector(), // Add AI model selector
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          ChatInputField(
            controller: _textController,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }

  // Chatbot header with close button
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'AI Chatbot',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // AI model selector widget
  Widget _buildModelSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Select AI Model: '),
          DropdownButton<String>(
            value: _selectedModel,
            items: <String>['Anthropic', 'Hugging Face']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedModel = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }
}

// Chat message model to differentiate between user and assistant messages
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

// Chat bubble widget to display messages
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Chat input field widget for sending text messages
class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;

  const ChatInputField({Key? key, required this.controller, required this.onSendMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: onSendMessage,
            backgroundColor: Colors.blueGrey,
            elevation: 0,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
