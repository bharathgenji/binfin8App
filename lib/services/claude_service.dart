// claude_service.dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'dart:io'; // For accessing environment variables or configurations

class ClaudeService {
  final AnthropicClient _client;

  // Initialize Claude client with API key
  ClaudeService()
      : _client = AnthropicClient(
          apiKey: Platform.environment['ANTHROPIC_API_KEY'] ?? ''  );

  // Send a standard message to Claude and receive a response
  Future<String> sendMessage(String prompt) async {
    try {
      final response = await _client.createMessage(
        request: CreateMessageRequest(
          model: Model.model(Models.claude35Sonnet20240620),
          maxTokens: 1024,
          messages: [
            Message(
              role: MessageRole.user,
              content: MessageContent.text(prompt),
            ),
          ],
        ),
      );
      return response.content.text;
    } catch (e) {
      print('Error sending message to Claude: $e');
      return 'Error processing your request. Please try again.';
    }
  }

  // Stream a response from Claude for real-time interactions
  Future<void> streamResponse(String prompt, Function(String) onStreamUpdate) async {
    try {
      final stream = _client.createMessageStream(
        request: CreateMessageRequest(
          model: Model.model(Models.claude35Sonnet20240620),
          maxTokens: 1024,
          messages: [
            Message(
              role: MessageRole.user,
              content: MessageContent.text(prompt),
            ),
          ],
        ),
      );

      await for (final res in stream) {
        res.map(
          messageStart: (MessageStartEvent e) {},
          messageDelta: (MessageDeltaEvent e) {},
          messageStop: (MessageStopEvent e) {},
          contentBlockStart: (ContentBlockStartEvent e) {},
          contentBlockDelta: (ContentBlockDeltaEvent e) {
            onStreamUpdate(e.delta.text);
          },
          contentBlockStop: (ContentBlockStopEvent e) {},
          ping: (PingEvent e) {},
        );
      }
    } catch (e) {
      print('Error streaming response from Claude: $e');
      onStreamUpdate('Error processing the request.');
    }
  }

  // Use custom tools to interact with Claude
  Future<String> useTool(String assetName, String detail) async {
    final request = CreateMessageRequest(
      model: Model.model(Models.claude35Sonnet20240620),
      messages: [
        Message(
          role: MessageRole.user,
          content: MessageContent.text('Provide the status of $assetName with $detail'),
        ),
      ],
      tools: [assetTool], // Using the assetTool defined below
      toolChoice: ToolChoice(
        type: ToolChoiceType.tool,
        name: assetTool.name,
      ),
      maxTokens: 1024,
    );

    final response = await _client.createMessage(request: request);
    return response.content.text;
  }

  // Clean up Claude session
  void endSession() {
    _client.endSession();
  }
}

// Define the assetTool used in the Claude service
const assetTool = Tool(
  name: 'get_asset_status',
  description: 'Fetches the current status or performance of a specified asset.',
  inputSchema: {
    'type': 'object',
    'properties': {
      'asset': {
        'type': 'string',
        'description': 'The name of the asset, e.g., Bitcoin.',
      },
      'details': {
        'type': 'string',
        'description': 'Specify details like current price or trend.',
      },
    },
    'required': ['asset'],
  },
);
