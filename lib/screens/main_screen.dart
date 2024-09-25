import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; // Import for biometric authentication
import 'chatbot_screen.dart'; // Import the Voice Command Prompt screen

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  // Method to authenticate the user using biometrics
  Future<bool> _authenticateUser(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isAuthenticated = false;

    if (canCheckBiometrics) {
      try {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to use voice commands',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      } catch (e) {
        print('Authentication error: $e');
      }
    }

    // If authenticated, navigate to the Voice Command Prompt screen
    if (isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotScreen(assets: [],)),
      );
    } else {
      _showAuthFailedDialog(context);
    }

    return isAuthenticated;
  }

  // Show a dialog if authentication fails
  void _showAuthFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: const Text('Unable to authenticate. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: const Text('Welcome to the Main Screen!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger biometric authentication before accessing voice commands
          _authenticateUser(context);
        },
        child: const Icon(Icons.mic),
        tooltip: 'Voice Command',
      ),
    );
  }
}
