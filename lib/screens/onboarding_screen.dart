import 'package:flutter/material.dart';
import 'package:asset_token_app/services/auth_service.dart'; // Adjust the import path based on your project structure
import 'asset_dashboard_screen.dart'; // Import your asset dashboard screen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final AuthService _authService = AuthService();

  // Trigger biometric authentication when "Get Started" is clicked
  Future<void> _onGetStartedPressed() async {
    bool canUseBiometrics = await _authService.checkBiometricsAvailable();
    if (canUseBiometrics) {
      bool isAuthenticated = await _authService.authenticateUserBiometrically();
      if (isAuthenticated) {
        // Navigate to the asset dashboard if authentication is successful
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
      _showAuthFailedDialog(
          'No Biometrics Available', 'Your device does not support biometric authentication.');
    }
  }

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
                _onGetStartedPressed(); // Retry authentication
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
        title: const Text('Onboarding'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Asset Tokenization App!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onGetStartedPressed, // Trigger biometric auth on button press
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
