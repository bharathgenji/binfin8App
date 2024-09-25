// asset_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:asset_token_app/services/web3_service.dart'; // Ensure correct import path
import 'package:asset_token_app/screens/chatbot_screen.dart';

class AssetDashboardScreen extends StatefulWidget {
  const AssetDashboardScreen({Key? key}) : super(key: key);

  @override
  _AssetDashboardScreenState createState() => _AssetDashboardScreenState();
}

class _AssetDashboardScreenState extends State<AssetDashboardScreen> {
  final Web3Service _web3Service = Web3Service();
  bool _isLoading = false;
  String userAddress = ''; // Replace with the actual wallet address
  BigInt _matBalance = BigInt.zero;
  int _decimals = 18; // Default to 18 decimals

  @override
  void initState() {
    super.initState();
    _fetchMATBalance();
  }

  // Fetch MAT token balance
  Future<void> _fetchMATBalance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Calling getMATBalance with address: $userAddress'); // Debug log
      BigInt balance = await _web3Service.getMATBalance(userAddress);
      print('MAT balance fetched: $balance'); // Debug log

      print('Calling getDecimals...'); // Debug log
      int decimals = await _web3Service.getDecimals();
      print('Decimals fetched: $decimals'); // Debug log

      setState(() {
        _matBalance = balance;
        _decimals = decimals;
      });
    } catch (e) {
      _showErrorDialog('Failed to load MAT token balance. Please try again.');
      print('Error fetching MAT balance: $e'); // Debug log
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Format the MAT balance for display
  String _formatBalance(BigInt balance, int decimals) {
    print('Formatting balance: $balance with decimals: $decimals'); // Debug log

    // Calculate the divisor based on the number of decimals
    final divisor = BigInt.from(10).pow(decimals);

    // Calculate the formatted balance
    final double formattedBalance = balance / divisor;
    return formattedBalance.toStringAsFixed(4); // Keep 4 decimal places
  }

  // Display error dialog
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

  // Open the chatbot as a bottom sheet
  void _openChatbot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatbotScreen(
        assets: [
          {
            'name': 'MAT Token',
            'type': 'Token',
            'value': _matBalance,
            'price': 1, // Assuming a price of 1 for display purposes
          },
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Dashboard'),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMATBalanceCard(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () => _openChatbot(context),
      ),
    );
  }

  // Build MAT balance display card
  Widget _buildMATBalanceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your MAT Token Balance:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_formatBalance(_matBalance, _decimals)} MAT',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchMATBalance,
              child: const Text('Refresh Balance'),
            ),
          ],
        ),
      ),
    );
  }
}
