import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:cropcart/Pages/Services/location_service.dart';
import 'package:cropcart/Pages/home_drawer.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentAddress = 'Fetching location...';
  final LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await locationService.getCurrentPosition();
      if (position != null) {
        String address = await locationService.getAddressFromLatLng(position);
        setState(() {
          currentAddress = address;
        });
      }
    } catch (e) {
      setState(() {
        currentAddress = e.toString();
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.035),
          child: Padding(
            padding: const EdgeInsets.only(right: 8, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 25,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      currentAddress,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 0,),
            Image.asset(
              'assets/app-logo.png',
              width: screenWidth * 0.25,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: const Text('Go to Profile Page.'),
      ),
    );
  }
}
