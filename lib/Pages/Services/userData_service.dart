// lib/Pages/Services/userData_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  Future<String> getUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          return userDoc.data()?['name'] ?? 'No Name';
        } else {
          return 'User not found';
        }
      } else {
        return 'Not logged in';
      }
    } catch (e) {
      return 'Error fetching data';
    }
  }
}
