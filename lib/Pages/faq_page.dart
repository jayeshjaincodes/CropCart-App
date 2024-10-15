import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ', style: TextStyle(fontSize: 20,color: Colors.white),),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white,),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _faqItem(
            question: '1. What is Crop Cart?',
            answer: 'Crop Cart is an e-commerce platform connecting farmers and suppliers to facilitate the sale of agricultural products directly to consumers.',
          ),
          _faqItem(
            question: '2. How do I register on Crop Cart?',
            answer: 'You can register by downloading the app and filling out the registration form with your details. After that, verify your email to complete the registration process.',
          ),
          _faqItem(
            question: '3. What types of products can I find on Crop Cart?',
            answer: 'Crop Cart offers a variety of agricultural products, including fresh fruits, vegetables, grains, and farming supplies.',
          ),
          _faqItem(
            question: '4. How can I track my orders?',
            answer: 'Once your order is placed, you can track its status in the "My Orders" section of the app.',
          ),
          _faqItem(
            question: '5. What payment methods are accepted?',
            answer: 'We accept various payment methods, including credit/debit cards, net banking, and popular e-wallets.',
          ),
          _faqItem(
            question: '6. How can I contact customer support?',
            answer: 'You can reach our customer support team through the "Contact Us" section in the app or via email at support@cropcart.com.',
          ),
          _faqItem(
            question: '7. Is there a return policy?',
            answer: 'Yes, we have a return policy that allows you to return products within 7 days of delivery. Please check the return policy section in the app for more details.',
          ),
          _faqItem(
            question: '8. Can I sell my products on Crop Cart?',
            answer: 'Absolutely! Farmers can sign up as suppliers and list their products for sale on the Crop Cart platform.',
          ),
          _faqItem(
            question: '9. How do I reset my password?',
            answer: 'If you forget your password, click on the "Forgot Password?" link on the login page, and follow the instructions to reset it.',
          ),
          _faqItem(
            question: '10. Is Crop Cart available in my area?',
            answer: 'Crop Cart is continuously expanding. You can check availability in your area by entering your location during registration or in the app settings.',
          ),
        ],
      ),
    );
  }

  Widget _faqItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}