import 'package:cropcart/Pages/Seller%20Dashboard/createProduct_page.dart';
import 'package:flutter/material.dart';

class SellerDashboardDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seller Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Manage your store efficiently',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text('Dashboard'),
                  onTap: () {
                    // Add functionality to show dashboard details if necessary
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text('All Products'),
                  onTap: () {
                    // Navigate to All Products Page
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('All Orders'),
                  onTap: () {
                    // Navigate to All Orders Page
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Create Product'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  CreateProductPage(),));
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.orange, // Text color
              ),
              onPressed: () {
                Navigator.pop(context); // Go back to the app
                Navigator.pop(context); // Go back to the app
              },
              child: Text('Go Back to App'),
            ),
          ),
        ],
      ),
    );
  }
}
