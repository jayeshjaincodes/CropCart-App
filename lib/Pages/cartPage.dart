import 'package:cropcart/Pages/checkout_page.dart';
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartPage({Key? key, required this.cartItems}) : super(key: key);

  // Function to group similar items and calculate total price
  List<Map<String, dynamic>> _groupCartItems() {
    final Map<String, Map<String, dynamic>> groupedItems = {};

    for (var item in cartItems) {
      final itemName = item['name'];
      if (groupedItems.containsKey(itemName)) {
        // Update quantity and total price
        groupedItems[itemName]!['quantity'] += 1;
        groupedItems[itemName]!['totalPrice'] += item['discountedPrice'];
      } else {
        groupedItems[itemName] = {
          'imageUrl': item['imageUrl'],
          'discountedPrice': item['discountedPrice'],
          'quantity': 1,
          'totalPrice': item['discountedPrice'],
        };
      }
    }

    return groupedItems.entries.map((e) {
      return {
        'name': e.key,
        'imageUrl': e.value['imageUrl'],
        'discountedPrice': e.value['discountedPrice'],
        'quantity': e.value['quantity'],
        'totalPrice': e.value['totalPrice'],
      };
    }).toList();
  }

  // Calculate the total amount for the cart
  double _calculateTotalAmount() {
    return cartItems.fold(0.0, (sum, item) => sum + item['discountedPrice']);
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupCartItems();
    final totalAmount = _calculateTotalAmount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: groupedItems.isEmpty
          ? const Center(child: Text('No items in the cart'))
          : ListView.builder(
              itemCount: groupedItems.length,
              itemBuilder: (context, index) {
                final item = groupedItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Image.network(
                      item['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['name']),
                    subtitle: Text(
                      'Rs ${item['discountedPrice']} x ${item['quantity']} = Rs ${item['totalPrice']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Logic to remove item from the cart
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs $totalAmount',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: groupedItems,
          totalAmount: totalAmount,
        ),
      ),
    );
  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
