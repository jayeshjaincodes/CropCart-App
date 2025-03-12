import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropcart/Pages/Services/userData_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController addressController = TextEditingController();
  String? userAddress;

  @override
  void initState() {
    super.initState();
    fetchUserAddress();
  }

  Future<void> fetchUserAddress() async {
    final userDataService = UserDataService();
    final userData = await userDataService.getUserData();

    if (userData.isNotEmpty && userData['fullAddress'] != null) {
      setState(() {
        userAddress = userData['fullAddress']; // Make sure the field matches
        addressController.text = userAddress ?? ''; // Populate the address field
      });
    } else {
      // Handle the case where user data is not available or address is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching address.')),
      );
    }
  }

  Future<void> confirmOrder() async {
    String address = addressController.text;
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a shipping address.'),
        ),
      );
      return;
    }

    // Prepare order data
    final orderData = {
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'address': address,
      'totalAmount': widget.totalAmount,
      'items': widget.cartItems.map((item) => {
        'name': item['name'],
        'price': item['discountedPrice'],
        'quantity': item['quantity'],
        'imageUrl': item['imageUrl'],
      }).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      // Save order to Firestore
      await FirebaseFirestore.instance.collection('orders').add(orderData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
        ),
      );

      // Optionally, navigate to a confirmation page or back to the cart
      Navigator.popUntil(context, (route) => route.isFirst); // Navigate back to the home screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your address',
                hintText: 'e.g. 123 Main St, City, Country',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    leading: Image.network(
                      item['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['name']),
                    subtitle: Text(
                      'Rs ${item['discountedPrice']} x ${item['quantity']}',
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rs ${widget.totalAmount}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: confirmOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }
}
