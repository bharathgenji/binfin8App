import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if biometric authentication is available on the device
  Future<bool> checkBiometricsAvailable() async {
    try {
      bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  // Authenticate user using biometric authentication (fingerprint, face, etc.)
  Future<bool> authenticateUserBiometrically() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your dashboard',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (e) {
      print('Error during biometric authentication: $e');
      return false;
    }
  }


  // Send Password Reset Email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted.';
      } else {
        return 'An unexpected error occurred: ${e.message}';
      }
    } catch (e) {
      return 'An unknown error occurred: $e';
    }
  }

  // Sign Up with Email and Password
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted.';
      } else {
        return 'An unexpected error occurred: ${e.message}';
      }
    } catch (e) {
      return 'An unknown error occurred: $e';
    }
  }

  // Sign In with Email and Password
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      // Attempt to sign in the user with the provided credentials
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Return null if login is successful
    } on FirebaseAuthException catch (e) {
      // Handle errors like wrong password or non-existent user
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted.';
      } else {
        return 'An unexpected error occurred: ${e.message}';
      }
    } catch (e) {
      return 'An unknown error occurred: $e';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
