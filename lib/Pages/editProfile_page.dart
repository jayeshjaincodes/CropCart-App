import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Map<String, dynamic>? userData; // To hold user data
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final UserDataService userDataService = UserDataService();

  // TextEditingControllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the page is initialized
  }

  Future<void> fetchUserData() async {
    try {
      final data = await userDataService.getUserData();
      print('Fetched user data: $data'); // Debug print

      if (data != null) {
        setState(() {
          userData = data; // Set the fetched data

          // Set controllers with existing data
          nameController.text = userData?['name'] ?? '';
          phoneController.text = userData?['phone_number'] ?? '';
          addressController.text = userData?['fullAddress'] ?? '';
          cityController.text = userData?['city'] ?? '';
          stateController.text = userData?['administrativeArea'] ?? '';
          pincodeController.text = userData?['pincode'] ?? '';
          countryController.text = userData?['country'] ?? '';
        });
      } else {
        print('No user data found'); // Log if no data is found
      }
    } catch (e) {
      print('Error fetching user data: $e'); // Log any errors
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> updateUserData() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty ||
        pincodeController.text.isEmpty ||
        countryController.text.isEmpty) {
      // Show a message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get the user ID from the current user
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Check if userId is valid
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Check if the document exists
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User document does not exist'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': nameController.text,
        'phone_number': phoneController.text,
        'fullAddress': addressController.text,
        'city': cityController.text,
        'administrativeArea': stateController.text,
        'pincode': pincodeController.text,
        'country': countryController.text,
      });
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error: $e'); // Log the error
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: userData == null // Check if userData is null
          ? const Center(child: CircularProgressIndicator())
          : userData!.containsKey('error')
              ? Center(child: Text(userData!['error']))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipPath(
                            clipper: BottomWaveClipper(),
                            child: Container(
                              width: double.infinity,
                              height: 180,
                              color: Colors.green,
                            ),
                          ),
                          Positioned(
                            top: 70,
                            left: (screenWidth / 2) - 50,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : null,
                                child: _selectedImage == null
                                    ? const Icon(Icons.camera_alt,
                                        size: 50, color: Colors.grey)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // First Name Field
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                labelStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Colors.green)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Phone Number
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Colors.green)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Address
                            TextFormField(
                              controller: addressController,
                              minLines: 1,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                  labelText: 'Address',
                                  labelStyle: TextStyle(color: Colors.black),
                                  prefixIcon: Icon(Icons.location_city),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.green))),
                            ),
                            const SizedBox(height: 16),

                            // City
                            TextFormField(
                              controller: cityController,
                              decoration: const InputDecoration(
                                  labelText: 'City',
                                  labelStyle: TextStyle(color: Colors.black),
                                  prefixIcon: Icon(Icons.location_on),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.green))),
                            ),
                            const SizedBox(height: 16),

                            // State and Pincode Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.43,
                                  child: TextFormField(
                                    controller: stateController,
                                    decoration: const InputDecoration(
                                      labelText: 'State',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2, color: Colors.green)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.43,
                                  child: TextFormField(
                                    controller: pincodeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Pincode',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2, color: Colors.green)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Country
                            TextFormField(
                              controller: countryController,
                              decoration: const InputDecoration(
                                labelText: 'Country',
                                labelStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.flag),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Colors.green)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Update Button
                            Container(
                              width: 150,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  updateUserData(); // Call update function
                                },
                                child: const Text(
                                  'Update',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
