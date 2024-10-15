import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcart/Pages/Auth/forgotpassword_page.dart';
import 'package:cropcart/Pages/Auth/signup_page.dart';
import 'package:cropcart/Pages/Services/location_service.dart';
import 'package:cropcart/Pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cropcart/Pages/Auth/Auth_service.dart';
import 'package:geolocator/geolocator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String currentAddress = 'Fetching location...';
  String locality = 'Fetching locality...';
  String city = ''; 
  String pincode = ''; 
  String country = ''; 
  String administrativeArea = '';
  final LocationService locationService = LocationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  final GoogleAuthService googleAuthService = GoogleAuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await locationService.getCurrentPosition();
      if (position != null) {
        String fullAddress = await locationService.getFullAddress(position);
        String loc = await locationService.getLocality(position);
        city = await locationService.getCity(position); // Get city
        pincode = await locationService.getPincode(position); // Get pincode
        country = await locationService.getCountry(position); 
        administrativeArea = await locationService.getAdministrativeArea(position);// Get country

        if (mounted) {
          setState(() {
            currentAddress = fullAddress; // Update full address
            locality = loc; // Update locality
          });
          // Store the data in Firestore
          await _storeLocationData(fullAddress, loc, city, pincode, country);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentAddress = e.toString();
          locality = 'Locality not found';
        });
      }
    }
  }

  Future<void> _storeLocationData(String fullAddress, String locality, String city, String pincode, String country) async {
    try {
      // Use the user's UID as the document ID to store user-specific data
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      // Create or update the document in Firestore
      await _firestore.collection('users').doc(uid).set({
        'fullAddress': fullAddress,
        'locality': locality,
        'city': city,
        'pincode': pincode,
        'country': country,
        'administrativeArea': administrativeArea
      }, SetOptions(merge: true)); // Merge to update without overwriting
    } catch (e) {
      print('Error storing location data: $e');
    }
  }
 Future<void> login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;

      // Check if user is not null
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'last_login': DateTime.now(), // Set last_login to current timestamp
        }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green, // Success color
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Email/password accounts are not enabled. Please contact support.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = '${e.message} Please try again.';
      }
      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          backgroundColor: Colors.red, // Error color
        ),
      );
    } catch (e) {
      // General error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red, // Error color
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
                      Image.asset(
                        'assets/app-logo.png',
                        width: screenWidth * 0.5,
                      ),
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 28,
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
                      // Password TextField
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: const Color(0xFFedf0f8),
                          filled: true,
                          hintText: 'Password',
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
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                minimumSize: Size(screenWidth * 0.7, 50),
                              ),
                              onPressed: (){login();
                              _getCurrentLocation();
                              _storeLocationData(currentAddress, locality, city, pincode, country);},
                              child: const Text('Login',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                            ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotpasswordPage(),
                              ));
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

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
                            onTap: () async{
                              GoogleAuthService.loginWithGoogle(context);
                              _getCurrentLocation();
                              _storeLocationData(currentAddress, locality, city, pincode, country);
                               
                            },
                            child: Image.asset(
                              "assets/google.png",
                              height: 35,
                              width: 45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New user? ',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignupPage()),
                              );
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange),
                            ),
                          )
                        ],
                      ),
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
