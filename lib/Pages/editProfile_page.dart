import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Map<String, dynamic>? userData;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final UserDataService userDataService = UserDataService();

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
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final data = await userDataService.getUserData();
      if (data != null && mounted) {
        setState(() {
          userData = data;
          nameController.text = userData?['name'] ?? '';
          phoneController.text = userData?['phone_number'] ?? '';
          addressController.text = userData?['fullAddress'] ?? '';
          cityController.text = userData?['city'] ?? '';
          stateController.text = userData?['administrativeArea'] ?? '';
          pincodeController.text = userData?['pincode'] ?? '';
          countryController.text = userData?['country'] ?? '';
        });
      } else {
        print('No user data found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('$userId.jpg');

      await storageRef.putFile(image);
      String downloadURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profile_image_url': downloadURL,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error uploading image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User document does not exist'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': nameController.text,
        'phone_number': phoneController.text,
        'fullAddress': addressController.text,
        'city': cityController.text,
        'administrativeArea': stateController.text,
        'pincode': pincodeController.text,
        'country': countryController.text,
      });

      if (_selectedImage != null) {
        await _uploadImage(_selectedImage!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error: $e');
    }
  }


  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightGreen.shade400,
                Colors.green,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: userData == null
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
                              width: screenWidth,
                              height: screenHeight * 0.23,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green, // Start color
                                    Colors.green.shade800, // End color
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: (screenWidth / 2) - 50,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (userData?['profile_image_url'] != null &&
                                            userData?['profile_image_url']
                                                .isNotEmpty)
                                        ? NetworkImage(
                                            userData!['profile_image_url'])
                                        : null,
                                child: _selectedImage == null &&
                                        (userData?['profile_image_url'] ==
                                                null ||
                                            userData!['profile_image_url']
                                                .isEmpty)
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
                                        width: 2, color: Colors.green)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: cityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                labelStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Colors.green)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: stateController,
                              decoration: const InputDecoration(
                                labelText: 'State',
                                labelStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.location_city_sharp),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Colors.green)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: pincodeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Pincode',
                                labelStyle: TextStyle(color: Colors.black),
                                prefixIcon: Icon(Icons.pin),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Colors.green)),
                              ),
                            ),
                            const SizedBox(height: 16),
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
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: updateUserData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Save Changes',style: TextStyle(color: Colors.white),),
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
        size.width / 4, size.height, size.width / 2, size.height - 30);
    path.quadraticBezierTo(
        size.width * 3 / 4, size.height - 60, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
