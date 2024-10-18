import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:cropcart/Pages/home_page.dart';
import 'package:cropcart/Pages/Auth/verifyEmail_page.dart'; // Import the verify email page
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Check if the user is logged in
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              User? user = snapshot.data;
              // Check if the email is verified
              if (user != null && user.emailVerified) {
                return const HomePage(); // Email is verified
              } else {
                // Pass the user to the VerifyEmailPage
                return VerifyEmailPage(user: user!); // Email is not verified
              }
            } else {
              return const LoginPage(); // User is not logged in
            }
          } else {
            // Show a loading indicator while waiting for the stream
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
