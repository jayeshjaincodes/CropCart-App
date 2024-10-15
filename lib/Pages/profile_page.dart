import 'dart:ui';
import 'package:cropcart/Pages/Auth/Auth_service.dart';
import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:cropcart/Pages/editProfile_page.dart';
import 'package:cropcart/Pages/viewProfile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  final UserDataService userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final data = await userDataService.getUserData();
    setState(() {
      userData = data;
    });
    print('Fetched user data: $userData');
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
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
                Colors.orange.shade100,
                Colors.orange,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : userData!.containsKey('error')
              ? Center(child: Text(userData!['error']))
              : RefreshIndicator(
                  onRefresh: fetchUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          width: screenWidth,
                          height: screenHeight * 0.30,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.amber],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    userData?['profile_image_url'] != null
                                        ? NetworkImage(
                                            userData!['profile_image_url'])
                                        : null,
                                child: userData?['profile_image_url'] == null
                                    ? const Icon(Icons.person,
                                        size: 40, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userData?['name']?.toUpperCase() ??
                                    'Loading...',
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                userData?['email'] ??
                                    'Phone Number not updated!',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              TextButton(
                                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfilePage(),));},
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.link,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'View Profile',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildProfileOption(
                              icon: Icons.info,
                              title: 'Edit Profile',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfilePage()));
                              },
                            ),
                            _buildProfileOption(
                              icon: Icons.shopping_bag,
                              title: 'My Orders',
                              onTap: () {
                                // Add functionality
                              },
                            ),
                            _buildProfileOption(
                              icon: Icons.lock,
                              title: 'Change Password',
                              onTap: () {
                                // Add functionality
                              },
                            ),
                            _buildProfileOption(
                              icon: Icons.file_copy,
                              title: 'Terms & Conditions',
                              onTap: () {
                                // Add functionality
                              },
                            ),
                           
                            _buildProfileOption(
                              icon: Icons.contact_mail,
                              title: 'About Us',
                              onTap: () {
                                // Add functionality
                              },
                            ),
                            _buildProfileOption(
                              icon: Icons.star,
                              title: 'Become a partner',
                              onTap: () {
                                // Add functionality
                              },
                            ),
                            _buildProfileOption(
                              icon: Icons.logout,
                              title: 'Logout',
                              onTap: () async {
                                logout();
                                await GoogleAuthService.logout(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileOption(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.orange),
              const SizedBox(width: 20),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
