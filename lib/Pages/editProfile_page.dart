import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
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

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
          _populateControllers(userData!);
        });
      } else {
        _showSnackBar('No user data found');
      }
    } catch (e) {
      _showSnackBar('Error fetching user data: $e');
    }
  }

  void _populateControllers(Map<String, dynamic> userData) {
    nameController.text = userData['name'] ?? '';
    phoneController.text = userData['phone_number'] ?? '';
    addressController.text = userData['fullAddress'] ?? '';
    cityController.text = userData['city'] ?? '';
    stateController.text = userData['administrativeArea'] ?? '';
    pincodeController.text = userData['pincode'] ?? '';
    countryController.text = userData['country'] ?? '';
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

      _showSnackBar('Image uploaded successfully', Colors.green);
    } catch (e) {
      _showSnackBar('Error uploading image: ${e.toString()}', Colors.red);
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

        if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fix the errors in the form', Colors.red);
      return;
    }

    if (_areFieldsEmpty()) {
      _showSnackBar('Please fill all fields', Colors.red);
      return;
    }

    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      _showSnackBar('User not found. Please log in again.', Colors.red);
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _showSnackBar('User document does not exist', Colors.red);
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

      _showSnackBar('Profile updated successfully', Colors.green);
    } catch (e) {
      _showSnackBar('Error updating profile: ${e.toString()}', Colors.red);
    }
  }

  bool _areFieldsEmpty() {
    return nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty ||
        pincodeController.text.isEmpty ||
        countryController.text.isEmpty;
  }

  void _showSnackBar(String message, [Color color = Colors.red]) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
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
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: _buildGradientBackground(),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : userData!.containsKey('error')
              ? Center(child: Text(userData!['error']))
              : SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildProfileHeader(
                          MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.height,
                        ),
                        _buildForm(),
                      ],
                    ),
                  ),
                ),
    );
  }


  Widget _buildGradientBackground() {
    return Container(
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
    );
  }

 Widget _buildProfileHeader(double screenWidth, double screenHeight) {
  return Stack(
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
                        userData!['profile_image_url'].isNotEmpty &&
                        !userData!['profile_image_url'].contains('No Profile Image'))
                    ? NetworkImage(userData!['profile_image_url'])
                    : null, // Set to null if there is no valid image URL
            child: _selectedImage == null &&
                    (userData?['profile_image_url'] == null ||
                        userData!['profile_image_url'].isEmpty ||
                        userData!['profile_image_url'].contains('No Profile Image'))
                ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                : null,
          ),
        ),
      ),
    ],
  );
}



  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField(nameController, 'First Name', Icons.person),
          const SizedBox(height: 16),
          _buildTextField(
            phoneController,
            'Phone Number',
            Icons.phone,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              } else if (value.length != 10) {
                return 'Phone number must be exactly 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(addressController, 'Address', Icons.location_city,
              minLines: 1, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(cityController, 'City', Icons.location_on),
          const SizedBox(height: 16),
          _buildTextField(stateController, 'State',
              Icons.location_city_sharp),
          const SizedBox(height: 16),
          _buildTextField(pincodeController, 'Pincode', Icons.pin,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField(countryController, 'Country', Icons.flag),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: updateUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData prefixIcon, {
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: const OutlineInputBorder(),
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
