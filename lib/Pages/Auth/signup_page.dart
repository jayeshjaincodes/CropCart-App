import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcart/Pages/Auth/Auth_service.dart';
import 'package:cropcart/Pages/Auth/wrapper.dart';
import 'package:cropcart/Pages/Services/location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/route_manager.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

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
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;


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

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential usercred =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        var data = {
          'name': nameController.text,
          'username': emailController.text.split('@')[0],
          'email': emailController.text,
          'created_at': DateTime.now(),
          'phone_number':''
        };

        if (usercred.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(usercred.user!.uid)
              .set(data);
        }

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green, // Success color
          ),
        );

        Get.offAll(const Wrapper());
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage =
                'This email address is already in use. Please try logging in.';
            break;
          case 'invalid-email':
            errorMessage =
                'The email address is not valid. Please enter a valid email.';
            break;
          case 'weak-password':
            errorMessage =
                'The password is too weak. Please use a stronger password.';
            break;
          case 'operation-not-allowed':
            errorMessage =
                'Email/password accounts are not enabled. Please contact support.';
            break;
          case 'network-request-failed':
            errorMessage =
                'Network error. Please check your internet connection and try again.';
            break;
          default:
            errorMessage =
                'An unexpected error occurred. Please try again later.';
        }
        // Error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error:$errorMessage'),
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
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/app-logo.png',
                        width: screenWidth * 0.5,
                      ),
                      const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Name TextField
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: const Color(0xFFedf0f8),
                          filled: true,
                          hintText: 'Name',
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
                        validator: ValidationBuilder().minLength(3).build(),
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
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                minimumSize: Size(screenWidth * 0.7, 50),
                              ),
                              onPressed: signUp,
                              child: const Text('Register',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                            ),
                      const SizedBox(height: 30),
                      const Text(
                        'OR Register with',
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
                          // const SizedBox(width: 30.0),
                          // InkWell(
                          //   onTap: () async {
                          //     try {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         const SnackBar(
                          //           content: Text('Apple sign-in successful!'),
                          //           backgroundColor: Colors.green,
                          //         ),
                          //       );
                          //     } catch (e) {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //           content: Text('Error: ${e.toString()}'),
                          //           backgroundColor: Colors.red,
                          //         ),
                          //       );
                          //     }
                          //   },
                          //   child: Image.asset(
                          //     "assets/apple.png",
                          //     height: 45,
                          //     width: 50,
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an Account? ',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Login',
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
