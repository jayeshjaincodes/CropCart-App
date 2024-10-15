import 'package:cropcart/Pages/Auth/Auth_service.dart';
import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:cropcart/Pages/faq_page.dart';
import 'package:cropcart/Pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Map<String, dynamic>? userData;
  final UserDataService userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _animationController.forward();
    fetchUserData(); // Fetch user data from Firestore
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    final data = await userDataService.getUserData();
    if (mounted) {
      setState(() {
        userData = data;
      });
    }
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
    return SlideTransition(
      position: _slideAnimation,
      child: Drawer(
        child: Column(
          children: [
            SizedBox(
              width: 220,
              child: DrawerHeader(
                padding: const EdgeInsets.all(21),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     CircleAvatar(
                                  radius:
                                      40, // You can adjust the radius as needed
                                  backgroundImage: userData?[
                                              'profile_image_url'] !=
                                          null
                                      ? NetworkImage(
                                          userData!['profile_image_url'])
                                      : null, // Use the image URL from userData
                                  child: userData?['profile_image_url'] ==
                                          null // Fallback if no image URL
                                      ? const Icon(Icons.person,
                                          size:
                                              30) // Default icon if no image is available
                                      : null,
                                ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        userData?['name'] != null
                            ? userData!['name'].split(' ')[0].toUpperCase()
                            : 'Loading...', // Fallback for null case
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _createDrawerItem(
                      icon: Icons.home,
                      text: 'HOME',
                      onTap: () {
                        Navigator.pop(context);
                      }),
                  _createDrawerItem(
                      icon: Icons.person,
                      text: 'MY PROFILE',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ));
                      }),
                  _createDrawerItem(
                      icon: Icons.receipt,
                      text: 'MY TRANSACTIONS',
                      onTap: () {}),
                  _createDrawerItem(
                      icon: Icons.contact_phone,
                      text: 'CONTACT US',
                      onTap: () {}),
                  _createDrawerItem(
                      icon: Icons.info, text: 'ABOUT US', onTap: () {}),
                  _createDrawerItem(
                      icon: Icons.help,
                      text: 'FAQ',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FAQPage(),
                            ));
                      }),
                  _createDrawerItem(
                      icon: Icons.star, text: 'RATE US', onTap: () {}),
                  _createDrawerItem(
                      icon: Icons.share, text: 'SHARE APP', onTap: () {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    '© Crop Cart',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      logout();
                      await GoogleAuthService.logout(context);
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Logout',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      GestureTapCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: ListTile(
        contentPadding: EdgeInsets.all(3),
        dense: true,
        title: Row(
          children: <Widget>[
            Icon(icon, color: Colors.green),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(text,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
