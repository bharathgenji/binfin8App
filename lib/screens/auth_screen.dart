import 'package:flutter/material.dart';
import 'package:asset_token_app/services/auth_service.dart'; // Adjust the import path based on your project structure
import 'asset_dashboard_screen.dart'; // Import your asset dashboard screen

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAndAuthenticateUser();
  }

  // Check and authenticate the user biometrically
  Future<void> _checkAndAuthenticateUser() async {
    bool canUseBiometrics = await _authService.checkBiometricsAvailable();
    if (canUseBiometrics) {
      bool isAuthenticated = await _authService.authenticateUserBiometrically();
      if (isAuthenticated) {
        // Navigate to the dashboard if authentication is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AssetDashboardScreen(),
          ),
        );
      } else {
        _showAuthFailedDialog('Authentication Failed', 'Please try again.');
      }
    } else {
      _showAuthFailedDialog('No Biometrics Available', 'Your device does not support biometric authentication.');
    }
  }

  // Show an alert dialog if authentication fails
  void _showAuthFailedDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkAndAuthenticateUser(); // Retry authentication
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Authentication'),
      ),
      body: const Center(
        child: Text(
          'Authenticating...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
