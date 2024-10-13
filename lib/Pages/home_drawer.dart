import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:cropcart/Pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  String userName = 'Fetching...';

  final UserDataService _userService = UserDataService(); 

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
    _fetchUserName(); // Fetch user data from Firestore
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  Future<void> _fetchUserName() async {
    final name = await _userService.getUserName(); // Fetch the user name using the service
    setState(() {
      userName = name;
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
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
              width: 200,
              child: DrawerHeader(
                padding: const EdgeInsets.all(21),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/app-logo.png'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                  _createDrawerItem(icon: Icons.home, text: 'HOME', onTap: () {}),
                  _createDrawerItem(icon: Icons.person, text: 'MY PROFILE', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage(),));
                  },),
                  _createDrawerItem(icon: Icons.receipt, text: 'MY TRANSACTIONS', onTap: () {}),
                  _createDrawerItem(icon: Icons.contact_phone, text: 'CONTACT US', onTap: () {}),
                  _createDrawerItem(icon: Icons.info, text: 'ABOUT US', onTap: () {}),
                  _createDrawerItem(icon: Icons.help, text: 'FAQ', onTap: () {}),
                  _createDrawerItem(icon: Icons.star, text: 'RATE US', onTap: () {}),
                  _createDrawerItem(icon: Icons.share, text: 'SHARE APP', onTap: () {}),
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
                    onPressed: logout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Logout', style: TextStyle(color: Colors.white)),
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

Widget _createDrawerItem({required IconData icon, required String text, GestureTapCallback? onTap}) {
  return Padding(
    padding: const EdgeInsets.only(left: 15),
    child: ListTile(
      contentPadding: EdgeInsets.zero, 
      dense: true, 
      title: Row(
        children: <Widget>[
          Icon(icon, color: Colors.green),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(text, style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
      onTap: onTap,
    ),
  );
}

}
