// lib/Pages/Services/userData_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Return all user data as a Map
          return {
            'name': userDoc.data()?['name'] ?? 'No Name',
            'username': userDoc.data()?['username'] ?? 'No Username',
            'email': userDoc.data()?['email'] ?? 'No Email',
            'city': userDoc.data()?['city'] ?? 'No City',
            'administrativeArea': userDoc.data()?['administrativeArea'] ?? 'No Administrative Area',
            'country': userDoc.data()?['country'] ?? 'No Country',
            'fullAddress': userDoc.data()?['fullAddress'] ?? 'No Address',
            'pincode': userDoc.data()?['pincode'] ?? 'No Pincode',
            'created_at': userDoc.data()?['created_at']?.toDate() ?? 'No Creation Date',
            'last_login': userDoc.data()?['last_login']?.toDate() ?? 'No Last Login Date',
            'phone_number': userDoc.data()?['phone_number'] ?? 'No Phone number'
          };
        } else {
          return {'error': 'User not found'};
        }
      } else {
        return {'error': 'Not logged in'};
      }
    } catch (e) {
      return {'error': 'Error fetching data: ${e.toString()}'};
    }
  }
}
