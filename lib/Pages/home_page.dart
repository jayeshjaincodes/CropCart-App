import 'package:cropcart/Pages/Auth/Auth_service.dart';
import 'package:cropcart/Pages/Auth/login_page.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:cropcart/Pages/home_drawer.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? userData;
  final UserDataService userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    fetchUserData();
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

    return userData == null // Check if userData is null
        ? const Center(child: CircularProgressIndicator())
        : userData!.containsKey('error')
            ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(userData!['error'],style: TextStyle(fontSize: 20),),
                const SizedBox(height: 60,),
                SizedBox(
                  width: screenWidth *0.5, 
                  child: ElevatedButton(onPressed: () async {
                      logout();
                      await GoogleAuthService.logout(context);
                      
                    },  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.logout,color: Colors.white,),
                      Text('Logout',style: TextStyle(color: Colors.white),),
                    ],
                  ),style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                )
              ],
            ))
            : Scaffold(
                drawer: CustomDrawer(),
                appBar: AppBar(
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(screenHeight * 0.035),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, left: 10),
                      child: Column(
                        children: [
                          Row(
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
                                    userData != null
                                        ? (userData!['fullAddress'] ?? 'No Address')
                                        : 'Fetching location...',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),
                  centerTitle: true,
                ),
                body: RefreshIndicator(
                  onRefresh: fetchUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      // Ensures the content is scrollable and pull-to-refresh is enabled
                      constraints: BoxConstraints(
                        minHeight: screenHeight,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: Text('Home page'))
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }
}
