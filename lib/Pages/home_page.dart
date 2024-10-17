import 'package:carousel_slider/carousel_slider.dart';
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

  // Carousel state
  int _currentIndex = 0;
  final List<String> imgList = [
    'assets/Banners/banner1.webp',
    'assets/Banners/banner2.jpeg',
    'assets/Banners/banner3.jpg',
    'assets/Banners/banner4.avif',
    'assets/Banners/banner5.webp',
    'assets/Banners/banner6.jpg',
    'assets/Banners/banner7.jpg',
  ];

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
                await GoogleAuthService.logout(context);
                logout();
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
                onPressed: _getCurrentLocation,
                icon: Icon(isLocationFetched
                    ? Icons.where_to_vote_rounded
                    : Icons.my_location, color: Colors.green),
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
          const IconButton(onPressed: null, icon: Icon(Icons.search, color: Colors.black)),
        ],
      ),
      centerTitle: true,
    ),
    body: RefreshIndicator(
      onRefresh: fetchUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              // CarouselSlider
              CarouselSlider(
                options: CarouselOptions(
                  height: screenHeight * 0.22,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: imgList.map((assetPath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: DecorationImage(
                            image: AssetImage(assetPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              // Dots indicator placed below the slider
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imgList.length, (index) => _buildDot(index == _currentIndex)),
                ),
              ),
              // Product categories grid
              _buildProductCategories(),
            ],
          ),
        ),
      ),
    ),
  );
}


  // Function to build the dot indicator
  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: isActive ? 10.0 : 8.0,
      width: isActive ? 10.0 : 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.grey, // Active dot color vs. inactive
      ),
    );
  }
}



Widget _buildProductCategories() {
  // Define the categories and images
  final List<Map<String, String>> categories = [
    {'name': 'Seeds and Plants', 'image': 'assets/Categories/seeds_and_plants.webp'},
    {'name': 'Fertilizers and Soil Enhancers', 'image':'assets/app-logo.png'},
    {'name': 'Pesticides and Insecticides', 'image': 'assets/app-logo.png'},
    {'name': 'Farm Equipment and Tools', 'image':'assets/app-logo.png'},
    {'name': 'Irrigation Systems and Accessories', 'image': 'assets/app-logo.png'},
    {'name': 'Livestock and Poultry Supplies', 'image': 'assets/app-logo.png'},
    {'name': 'Agrochemicals and Plant Growth Regulators', 'image': 'assets/app-logo.png'},
    {'name': 'Greenhouse and Nursery Supplies', 'image': 'assets/app-logo.png'},
    {'name': 'Machinery and Farm Vehicles', 'image': 'assets/app-logo.png'},
    {'name': 'Protective Gear and Safety Equipment', 'image': 'assets/app-logo.png'},
    {'name': 'Organic Farming Supplies', 'image': 'assets/app-logo.png'},
    {'name': 'Packaging and Storage Solutions', 'image':'assets/app-logo.png'},
    {'name': 'Weather Monitoring and Farm Management Tools', 'image':'assets/app-logo.png'},
    {'name': 'Animal Husbandry Supplies', 'image': 'assets/app-logo.png'},
    {'name': 'Renewable Energy Solutions', 'image': 'assets/app-logo.png'},
  ];

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Product Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                // Navigate to the full categories page
              },
              child: Row(
                children: const [
                  Text('View All', style: TextStyle(color: Colors.green)),
                  Icon(Icons.arrow_forward, color: Colors.green),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns in the grid
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.63,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryItem(categories[index]['name']!, categories[index]['image']!);
          },
        ),
      ],
    ),
  );
}

// Function to create each category item in the grid
Widget _buildCategoryItem(String name, String imagePath) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 2,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleAvatar(
          radius: 30,           backgroundImage: AssetImage(imagePath), // Set the background image
          backgroundColor: Colors.transparent, 
        ),

        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0,right: 8),
            child: Text(
              name,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    ),
  );
}
