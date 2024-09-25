// huggingface_service.dart
import 'package:dio/dio.dart';

class HuggingFaceService {
  final String _apiUrl = 'https://api-inference.huggingface.co/models/EleutherAI/gpt-neo-2.7B'; // GPT-Neo Model URL
  final String _apiKey = ''; // Replace with your actual API key

  // Send a message to the GPT-Neo model and receive a response
  Future<String> sendMessage(String prompt) async {
    try {
      final dio = Dio();

      // Refine the prompt with few-shot learning technique
      final refinedPrompt = '''
        You are an expert financial assistant who helps users manage their portfolios by analyzing current assets and suggesting new investment opportunities.

        Example 1:
        User Portfolio: Bitcoin, Ethereum, USDT.
        User Query: "Based on my current portfolio, what assets should I consider buying?"
        Assistant Response: "Based on your portfolio, you may want to consider diversifying with assets like Cardano (ADA), Solana (SOL), or exploring DeFi tokens like Aave (AAVE)."

        Example 2:
        User Portfolio: Rare NFT, Bitcoin.
        User Query: "What should I add to my investment mix?"
        Assistant Response: "You have a strong foundation with Bitcoin and NFTs. Consider adding stablecoins for liquidity and exploring emerging assets like Polkadot (DOT) for more diversification."

        User Portfolio: Bitcoin, Ethereum, Rare NFT, and USDT.
        User Query: "$prompt"
        Assistant Response:
      ''';

      final response = await dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'inputs': refinedPrompt,
        },
      );

      if (response.statusCode == 200) {
        final generatedText = response.data[0]['generated_text'];
        return generatedText ?? 'No response generated.';
      } else {
        return 'Error: Received unexpected response with status code ${response.statusCode}.';
      }
    } catch (e) {
      print('Error sending message to GPT-Neo: $e');
      return 'Error processing your request. Please try again.';
    }
  }
}
