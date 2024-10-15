import 'dart:ui';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:cropcart/Pages/editProfile_page.dart';
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: userData == null // Check if userData is null
          ? const Center(child: CircularProgressIndicator())
          : userData!.containsKey('error')
              ? Center(child: Text(userData!['error']))
              : RefreshIndicator(
                  onRefresh: fetchUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(13.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          height: screenHeight * 0.35,
                          width: screenWidth,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  maxRadius: 30,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),

                                // Display Name
                                Text(
                                  userData != null
                                      ? (userData!['name'] ?? 'No Name')
                                      : 'Loading...',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),

                                // Display Phone Number or Message
                                Text(
                                  userData != null
                                      ? (userData!['phone_number'] ??
                                          'Phone Number not updated!')
                                      : 'Loading...',
                                  style: TextStyle(
                                    color: userData != null &&
                                            userData!['phone_number'] != null
                                        ? Colors.grey[600]
                                        : Colors.red,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                // Display City
                                Center(
                                  child: Text(
                                    userData != null
                                        ? (userData!['city'] ?? 'No City')
                                        : 'Loading...',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 5),

                                // Display Full Address
                                Center(
                                  child: Text(
                                    userData != null
                                        ? (userData!['fullAddress'] ??
                                            'No Address')
                                        : 'Loading...',
                                    style: TextStyle(color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.link,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'View Profile',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProfilePage()));
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.edit_document,
                                            size: 20,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Edit Profile',
                                            style:
                                                TextStyle(color: Colors.orange),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            width: screenWidth,
                            height: screenHeight * 0.2,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
