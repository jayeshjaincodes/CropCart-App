import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcart/Pages/Auth/Auth_service.dart';
import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:cropcart/Pages/Services/location_service.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
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
  Map<String, dynamic>? userData;
  final UserDataService userDataService = UserDataService();
  final LocationService locationService = LocationService();
  
  // Location data
  String currentAddress = 'Fetching location...';
  String locality = 'Fetching locality...';
  String city = '';
  String pincode = '';
  String country = '';
  String administrativeArea = '';
  
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Flag to track if the location has been fetched
  bool isLocationFetched = false; 

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _getCurrentLocation(); // Automatically fetch location on startup
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await locationService.getCurrentPosition();
      if (position != null) {
        await _updateLocationData(position);
      }
    } catch (e) {
      setState(() {
        currentAddress = e.toString();
        locality = 'Locality not found';
      });
    }
  }

  Future<void> _updateLocationData(Position position) async {
    String fullAddress = await locationService.getFullAddress(position);
    String loc = await locationService.getLocality(position);
    city = await locationService.getCity(position);
    pincode = await locationService.getPincode(position);
    country = await locationService.getCountry(position);
    administrativeArea = await locationService.getAdministrativeArea(position);

    setState(() {
      currentAddress = fullAddress;
      locality = loc;
      isLocationFetched = true;
    });

    await _storeLocationData();
  }

  Future<void> _storeLocationData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      await _firestore.collection('users').doc(uid).set({
        'fullAddress': currentAddress,
        'locality': locality,
        'city': city,
        'pincode': pincode,
        'country': country,
        'administrativeArea': administrativeArea
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error storing location data: $e');
    }
  }

  Future<void> fetchUserData() async {
    final data = await userDataService.getUserData();
    setState(() {
      userData = data;
    });
    print('Fetched user data: $userData');
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (userData!.containsKey('error')) {
      return _buildErrorScreen(screenWidth);
    } else {
      return _buildMainScreen(screenWidth, screenHeight);
    }
  }

  Widget _buildErrorScreen(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(userData!['error'], style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 60),
          SizedBox(
            width: screenWidth * 0.5,
            child: ElevatedButton(
              onPressed: () async {
                logout();
                await GoogleAuthService.logout(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.logout, color: Colors.white),
                  Text('Logout', style: TextStyle(color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreen(double screenWidth, double screenHeight) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.060),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 25),
                const SizedBox(width: 9),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      userData!['fullAddress'] ?? 'No Address',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _getCurrentLocation, // Directly call the method
                  icon: Icon(isLocationFetched
                      ? Icons.where_to_vote_rounded
                      : Icons.my_location,color:Colors.green),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 0),
            Image.asset('assets/app-logo.png', width: screenWidth * 0.25),
            const IconButton(onPressed: null, icon: Icon(Icons.search,color: Colors.black,)),
          ],
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: const Center(child: Text('Home page')),
          ),
        ),
      ),
    );
  }
}
