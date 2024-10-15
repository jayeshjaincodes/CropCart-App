import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:cropcart/Pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  // Login method
  static Future<void> loginWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.signOut(); // Ensure to sign out of Google

      final GoogleSignInAccount? gUser = await googleSignIn.signIn();
      if (gUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login cancelled.')),
        );
        return;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        DocumentSnapshot userSnapshot = await userDoc.get();

        String existingPhoneNumber = _getExistingPhoneNumber(userSnapshot);

        // Prepare user data
        var userData = {
          'name': gUser.displayName ?? '',
          'username': gUser.email.split('@')[0],
          'email': gUser.email,
          'last_login': DateTime.now(),
          'phone_number': existingPhoneNumber,
          'created_at': DateTime.now(), // Always set to current time initially
        };

        // If the user document already exists, update the last_login and phone_number
        if (userSnapshot.exists) {
          userData.remove('created_at'); // Remove created_at for existing users
        }

        // Store or update user data in Firestore
        await userDoc.set(userData, SetOptions(merge: true)); // Use merge to avoid overwriting existing data
      }

      if (context.mounted) {
        await Future.delayed(const Duration(milliseconds: 100)); // Optional delay
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'operation-not-allowed') {
        errorMessage = 'Google sign-in is not enabled.';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Logout method
  static Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), // Navigate to your LoginPage
      );
    }
  }

  // Helper method to get existing phone number safely
  static String _getExistingPhoneNumber(DocumentSnapshot userSnapshot) {
    if (userSnapshot.exists && userSnapshot.data() != null) {
      var data = userSnapshot.data() as Map<String, dynamic>;
      return data['phone_number'] ?? ''; // Return empty string if field does not exist
    }
    return ''; // Return empty string if snapshot does not exist
  }
}
