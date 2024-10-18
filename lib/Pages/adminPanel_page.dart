import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    QuerySnapshot querySnapshot = await _firestore.collection('sellerApplications').get();
    setState(() {
      applications = querySnapshot.docs;
    });
  }

  Future<void> _acceptApplication(String userId, String applicationId) async {
    await _firestore.collection('sellerApplications').doc(applicationId).update({
      'status': 'approved',
    });

    await _firestore.collection('users').doc(userId).update({
      'role': 'seller',
    });

    _fetchApplications();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application approved successfully!')),
    );
  }

  void _showApplicationDetails(DocumentSnapshot application) {
    showDialog(
      context: context,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        return AlertDialog(
          title: Text(
            'Application Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: screenWidth, 
              padding: EdgeInsets.all(screenWidth * 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Business Name:', application['businessName']),
                  _buildDetailRow('Contact Number:', application['phoneNumber']),
                  _buildDetailRow('Email:', application['businessMail']),
                  _buildDetailRow('GST Number:', application['gstNumber']),
                  _buildDetailRow('Address:', application['address']),
                  _buildDetailRow('Description:', application['description']),
                  _buildDetailRow('Status:', application['status']),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _acceptApplication(application['userId'], application.id);
                Navigator.of(context).pop();
              },
              child: Text('Accept', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: applications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(application['businessName'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Status: ${application['status']}', style: TextStyle(color: Colors.grey[600])),
                    trailing: Icon(Icons.arrow_forward, color: Colors.orange),
                    onTap: () => _showApplicationDetails(application),
                    tileColor: Colors.white,
                  ),
                );
              },
            ),
    );
  }
}
