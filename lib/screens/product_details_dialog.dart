import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProductDetailsDialog extends StatefulWidget {
  final Map<String, dynamic>? product;
  final VoidCallback onSave;

  ProductDetailsDialog({this.product, required this.onSave});

  @override
  _ProductDetailsDialogState createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  List<File?> _images = [null, null, null];
  List<String?> _imageUrls = [null, null, null]; // To store existing image URLs
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isAvailable = true;
  String _selectedProductType = 'Electronics'; // Default selected type

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _descriptionController.text = widget.product!['description'] ?? '';
      _priceController.text = widget.product!['price'].toString();
      _isAvailable = widget.product!['isAvailable'] ?? true;
      _imageUrls[0] = widget.product!['imageUrl1'];
      _imageUrls[1] = widget.product!['imageUrl2'];
      _imageUrls[2] = widget.product!['imageUrl3'];
      _selectedProductType = widget.product!['productType'] ??
          'Electronics'; // Set the product type
    }
  }

  void _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images[index] = File(pickedFile.path);
      });
    }
  }

  void _saveProduct() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Prepare to store image URLs
    List<String?> imageUrls = _imageUrls; // Start with existing URLs
    for (int i = 0; i < _images.length; i++) {
      if (_images[i] != null) {
        // New image picked
        final ref = FirebaseStorage.instance
            .ref()
            .child('store_owner_products')
            .child(user.uid)
            .child(
                '${widget.product?['id'] ?? DateTime.now().toString()}_$i.jpg');
        await ref.putFile(_images[i]!);
        final url = await ref.getDownloadURL();
        imageUrls[i] = url; // Update with new URL
      }
    }

    final productData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'isAvailable': _isAvailable,
      'productType': _selectedProductType, // Add product type to data
      'imageUrl1': imageUrls[0],
      'imageUrl2': imageUrls[1],
      'imageUrl3': imageUrls[2],
      'storeId': user.uid, // Include the storeId
    };

    if (widget.product != null) {
      await _firestore
          .collection('storeOwners')
          .doc(user.uid)
          .collection('products')
          .doc(widget.product!['id'])
          .update(productData);

      // Show success message for update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await _firestore
          .collection('storeOwners')
          .doc(user.uid)
          .collection('products')
          .add(productData);

      // Show success message for add
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    widget.onSave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.product == null ? 'Add Product' : 'Edit Product',
        style: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Product Description',
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedProductType,
              items: ['Electronics', 'Hardware', 'Plumbing Materials']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProductType = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Product Type',
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text('Available'),
              activeColor: Colors.blue,
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: () => _pickImage(index),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: _images[index] != null
                        ? Image.file(_images[index]!, fit: BoxFit.cover)
                        : (_imageUrls[index] != null
                            ? Image.network(_imageUrls[index]!,
                                fit: BoxFit.cover)
                            : Icon(Icons.add_photo_alternate,
                                color: Colors.blue.shade700)),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white), // White text color
          ),
        ),
      ],
    );
  }
}
