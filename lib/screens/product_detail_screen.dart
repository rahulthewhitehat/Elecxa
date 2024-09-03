import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'showStoreDetailsScreen.dart'; // Ensure this import if using ShowStoreDetailsScreen

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailScreen({required this.product});

  void _navigateToStoreDetails(BuildContext context) async {
    final storeId = product['storeId']; // Ensure 'storeId' is present

    // Debugging statement to print product data
    print("Product Data: $product");

    if (storeId != null) {
      final storeDoc = await FirebaseFirestore.instance
          .collection('storeOwners')
          .doc(storeId)
          .get();

      if (storeDoc.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowStoreDetailsScreen(
              store: storeDoc.data() as Map<String, dynamic>,
            ),
          ),
        );
      } else {
        // Store document does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Store details not found.')),
        );
      }
    } else {
      // storeId is missing or null in product
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Store ID not available.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Product Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product['imageUrl1'] != null)
              Image.network(product['imageUrl1'], width: 150, height: 150),
            Text('Name: ${product['name']}', style: TextStyle(fontSize: 18)),
            Text('Type: ${product['productType']}',
                style: TextStyle(fontSize: 18)),
            Text('Price: ₹${product['price']}', style: TextStyle(fontSize: 18)),
            Text('Available: ${product['isAvailable'] ? 'Yes' : 'No'}',
                style: TextStyle(fontSize: 18)),
            Text('Description: ${product['description']}',
                style: TextStyle(fontSize: 18)),
            Spacer(),
            ElevatedButton(
              onPressed: () => _navigateToStoreDetails(context),
              child: Text('About Store'),
            ),
          ],
        ),
      ),
    );
  }
}
