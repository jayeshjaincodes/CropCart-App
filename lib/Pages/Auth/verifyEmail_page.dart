import 'dart:async'; // Import Timer class
import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:cropcart/Pages/Auth/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class VerifyEmailPage extends StatefulWidget {
  final User user;

  const VerifyEmailPage({Key? key, required this.user}) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer; // Timer for checking email verification
  Timer? _countdownTimer; // Timer for countdown
  bool _canResend = true; // Flag to control resend button
  int _remainingSeconds = 60; // Countdown value

  @override
  void initState() {
    super.initState();
    checkEmailVerification();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the verification timer
    _countdownTimer?.cancel(); // Cancel the countdown timer
    super.dispose();
  }

  void checkEmailVerification() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      User? user = _auth.currentUser; // Get the current user
      if (user != null) {
        await user.reload(); // Reload user to get updated verification status
        if (user.emailVerified) {
          // If verified, redirect to the main app page
          Get.offAll(const Wrapper());
          timer.cancel(); // Cancel the timer once the user is verified
        }
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    if (_canResend) {
      setState(() {
        _canResend = false; // Disable the button
        _remainingSeconds = 60; // Reset countdown
      });

      try {
        await widget.user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
          ),
        );

        // Start the countdown timer
        _startCountdown();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'too-many-requests') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Too many requests. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Handle other errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true; // Re-enable the button
          _countdownTimer?.cancel(); // Stop the countdown
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: Image.asset(
              'assets/login-bg.jpg',
              width: screenWidth,
              height: screenHeight * 0.4,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth * 0.85,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));; // Navigate back on press
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                          Center(
                            child: Image.asset(
                              'assets/app-logo.png',
                              width: screenWidth * 0.5,
                            ),
                          ),
                        ],
                      ),
                    const Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      'A verification email has been sent to your email address.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    // Show countdown timer
                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: Size(screenWidth * 0.7, 50),
                      ),
                      onPressed: _canResend ? _sendVerificationEmail : null,
                      child: const Text('Resend Link',
                          style: TextStyle(
                              fontSize: 18, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    if (!_canResend)
                      Text(
                        'You can resend the link in $_remainingSeconds seconds',
                        style: const TextStyle(fontSize: 15),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
