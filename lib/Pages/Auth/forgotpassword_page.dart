import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cropcart/Pages/Auth/Auth_service.dart';

class ForgotpasswordPage extends StatefulWidget {
  const ForgotpasswordPage({super.key});

  @override
  State<ForgotpasswordPage> createState() => _ForgotpasswordPageState();
}

class _ForgotpasswordPageState extends State<ForgotpasswordPage> {
  final GoogleAuthService googleAuthService = GoogleAuthService();

  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  bool _isLoading = false; // Loading state

  forgot() async {
    if (_formKey.currentState!.validate()) {
      // Validate form
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text);
        Navigator.pop(context);
        // If the email is valid, show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent! Check your email.'),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Invalid email address';
        if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } else if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        }

        // Show the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        // For any other unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // End loading
        });
      }
    }
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
                child: Form(
                  key: _formKey, // Assign the form key here
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context); // Navigate back on press
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
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Email TextField
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: const Color(0xFFedf0f8),
                          filled: true,
                          hintText: 'Email',
                          hintStyle: const TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.orange),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.orange),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 9, horizontal: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // Login Button
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                minimumSize: Size(screenWidth * 0.7, 50),
                              ),
                              onPressed: () {
                                forgot(); // Call your forgot function
                              },
                              child: const Text('Reset Password',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                            ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 20),
                      const Text(
                        'OR Login with',
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              GoogleAuthService.loginWithGoogle(context);
                            },
                            child: Image.asset(
                              "assets/google.png",
                              height: 35,
                              width: 45,
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 30.0)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
