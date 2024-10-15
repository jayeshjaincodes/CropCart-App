import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({Key? key}) : super(key: key);

  @override
  _ViewProfilePageState createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: $e')),
      );
    }
  }

  String _formatDateTime(Timestamp timestamp) {
    // Format the date and time to a more readable format
    return DateFormat('dd MMMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile image section with updated design
                  Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: userData?['profile_image_url'] != null
                              ? NetworkImage(userData!['profile_image_url'])
                              : null,
                          child: userData?['profile_image_url'] == null
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userData?['name'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // User details in cards
                  _buildInfoCard(Icons.email, 'Email', userData?['email']),
                  _buildInfoCard(Icons.phone, 'Phone Number', userData?['phone_number']),
                  _buildInfoCard(Icons.home, 'Full Address', userData?['fullAddress']),
                  _buildInfoCard(Icons.location_city, 'Locality', userData?['locality']),
                  _buildInfoCard(Icons.location_on, 'State', userData?['administrativeArea']),
                  _buildInfoCard(Icons.location_on, 'Country', userData?['country']),
                  _buildInfoCard(Icons.access_time, 'Last Login', userData?['last_login'] != null 
                      ? _formatDateTime(userData!['last_login']) 
                      : 'N/A'),
                  _buildInfoCard(Icons.calendar_today, 'Created At', userData?['created_at'] != null 
                      ? _formatDateTime(userData!['created_at']) 
                      : 'N/A'),
                  const SizedBox(height: 20),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    '© Crop Cart',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
        color: Colors.white,
        child: ListTile(
          leading: Icon(icon, color: Colors.grey),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            value ?? 'N/A',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
