import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

logout()
async{
  await FirebaseAuth.instance.signOut();
  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Home Page '),
            InkWell(onTap: logout,child: Icon(Icons.logout))
          ],
        ),
      ),
    );
  }
}
