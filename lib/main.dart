import 'dart:io';
import 'package:cropcart/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyDE5nrPaBXssFZ7bEPy6FtpKVl2Zjey8S0",
            appId: "1:1037467007539:android:189d5273d00160f472c146",
            messagingSenderId: "1037467007539",
            projectId: "crop-cart",
          ),
        )
      : Firebase.initializeApp();
  Platform.isIOS
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyCaoSmxpbUwqshsLmxjeHSaA9iRAPZMejs',
            appId: '1:1037467007539:ios:7d98d5090293d30a72c146',
            messagingSenderId: '1037467007539',
            projectId: 'crop-cart',
          ),
        )
      : Firebase.initializeApp();
  runApp(const MyApp());
}
 class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  Wrapper(),
    );
  }
}