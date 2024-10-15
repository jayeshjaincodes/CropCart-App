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
      
      // Check if user already exists in Firestore
      User? user = userCredential.user;
      if (user != null) {
        // Reference to the user document in Firestore
        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        // Fetch user data from Firestore
        DocumentSnapshot userSnapshot = await userDoc.get();

        // Get existing phone number if available, otherwise set to an empty string
        String existingPhoneNumber = userSnapshot.exists && userSnapshot['phone_number'] != null
            ? userSnapshot['phone_number']
            : '';

        // Prepare user data
        var userData = {
          'name': gUser.displayName ?? '',
          'username': gUser.email.split('@')[0],
          'email': gUser.email,
          'last_login': DateTime.now(), 
          'phone_number': existingPhoneNumber, // Use existing phone number
        };

        // Only set created_at if the user document does not exist
        if (!userSnapshot.exists) {
          userData['created_at'] = DateTime.now(); // Set created_at for new users
        }

        // Store or update user data in Firestore
        await userDoc.set(userData, SetOptions(merge: true)); // Use merge to avoid overwriting existing data
      }

      // Navigate to HomePage
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
}
