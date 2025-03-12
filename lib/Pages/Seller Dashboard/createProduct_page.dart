import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateProductPage extends StatefulWidget {
  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Storage instance
  final ImagePicker _picker = ImagePicker();

  // Form fields
  String? _productName;
  String? _description;
  String? _category;
  double? _originalPrice;
  double? _discountedPrice;
  int? _stock;
  File? _imageFile; // Added for image file

  // Loading state
  bool _isLoading = false; // New loading state variable

  // Fixed categories
  final List<Map<String, String>> categories = [
    {'name': 'Seeds and Plants'},
    {'name': 'Fertilizers and Soil Enhancers'},
    {'name': 'Pesticides and Insecticides'},
    {'name': 'Farm Equipment and Tools'},
    {'name': 'Irrigation Systems and Accessories'},
    {'name': 'Livestock and Poultry Supplies'},
    {'name': 'Agrochemicals and Plant Growth Regulators'},
    {'name': 'Greenhouse and Nursery Supplies'},
    {'name': 'Machinery and Farm Vehicles'},
    {'name': 'Protective Gear and Safety Equipment'},
    {'name': 'Organic Farming Supplies'},
    {'name': 'Packaging and Storage Solutions'},
    {'name': 'Weather Monitoring and Farm Management Tools'},
    {'name': 'Animal Husbandry Supplies'},
    {'name': 'Renewable Energy Solutions'},
  ];

  Future<void> _createProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true; // Start loading
      });

      String? imageUrl;

      // Upload the image to Firebase Storage if an image is selected
      if (_imageFile != null) {
        final ref = _storage.ref().child('product_images/${DateTime.now().toIso8601String()}');
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL(); // Get the download URL
      }

      await _firestore.collection('products').add({
        'name': _productName,
        'description': _description,
        'category': _category,
        'originalPrice': _originalPrice,
        'discountedPrice': _discountedPrice,
        'stock': _stock,
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product created successfully!')),
      );

      setState(() {
        _isLoading = false; // Stop loading
      });

      Navigator.pop(context);
    }
  }

  void _selectCategory(String category) {
    setState(() {
      _category = category;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Create Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Product Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Image Upload Section
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                              child: _imageFile != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _pickImage,
                              child: Text('Upload Image'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Form fields
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          prefixIcon: Icon(Icons.production_quantity_limits),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a product name';
                          }
                          return null;
                        },
                        onSaved: (value) => _productName = value,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        onSaved: (value) => _description = value,
                      ),
                      SizedBox(height: 20),
                      ListTile(
                        title: Text(_category ?? 'Select Category'),
                        leading: Icon(Icons.category),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.arrow_drop_down),
                          onSelected: _selectCategory,
                          itemBuilder: (BuildContext context) {
                            return categories.map((category) {
                              return PopupMenuItem<String>(
                                value: category['name'],
                                child: Text(category['name']!),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Original Price',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the original price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) => _originalPrice = double.tryParse(value!),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Discounted Price',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          prefixIcon: Icon(Icons.local_offer),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the discounted price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) => _discountedPrice = double.tryParse(value!),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          prefixIcon: Icon(Icons.store),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the stock quantity';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) => _stock = int.tryParse(value!),
                      ),
                      SizedBox(height: 20),

                      // Create Product Button
                      _isLoading // Show circular progress indicator if loading
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                            child: ElevatedButton(
                                onPressed: _createProduct,
                                child: Text('Create Product'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
