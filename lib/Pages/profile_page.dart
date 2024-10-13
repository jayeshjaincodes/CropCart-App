import 'dart:ui';

import 'package:cropcart/Pages/Services/location_service.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Fetching...';
  final UserDataService _userService = UserDataService();
  String currentAddress = 'Fetching location...';
  String locality = 'Fetching Locality...';
  final LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _getCurrentLocation();
  }

  Future<void> _fetchUserName() async {
    final name = await _userService.getUserName();
    setState(() {
      userName = name;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await locationService.getCurrentPosition();
      if (position != null) {
        String address = await locationService.getAddressFromLatLng(position);
        _extractLocality(address); // Extract locality from the full address
        setState(() {
          currentAddress = address; // Store the full address
        });
      }
    } catch (e) {
      setState(() {
        currentAddress = e.toString();
        locality = 'Locality not found'; // Handle error case for locality
      });
    }
  }

  // New method to extract locality from the full address
  void _extractLocality(String address) {
    final parts = address.split(','); // Split the address by commas
    if (parts.length > 1) {
      setState(() {
        locality = parts[parts.length - 3]
            .trim(); // Assuming locality is the third last part
      });
    } else {
      setState(() {
        locality = 'Locality not found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          height: screenHeight * 0.30,
          width: screenWidth,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(maxRadius: 30,),
                const SizedBox(height: 12,),
                Text(
                  '${userName}'.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight
                          .w500), // Added styling for better visibility
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: Text(
                  '${locality}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                )),
                const SizedBox(
                  height: 5,
                ),
                Center(
                    child: Text(
                  '${currentAddress}',
                  style: TextStyle( color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(onPressed: () {
                      
                    }, child: Row(
                      children: [
                        Icon(Icons.link,color: Colors.blue,),
                        SizedBox(width: 10,),
                        Text('View Profile',style: TextStyle(color:Colors.blue ),)
                      ],
                    ),
                    ),
                    TextButton(onPressed: () {
                      
                    }, child: Row(
                      children: [
                        Icon(Icons.edit_document,size: 20,color: Colors.orange,),
                        SizedBox(width: 10,),
                        Text('Edit Profile',style: TextStyle(color: Colors.orange),)
                      ],
                    ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
