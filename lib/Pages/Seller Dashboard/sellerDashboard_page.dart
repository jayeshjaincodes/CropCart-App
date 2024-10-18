import 'package:flutter/material.dart';
import 'sellerDashboard_drawer.dart';

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Dashboard',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.orange,
      ),
      drawer: SellerDashboardDrawer(),
      body: Center(
        child: Text('Welcome to your Seller Dashboard!'),
      ),
    );
  }
}
