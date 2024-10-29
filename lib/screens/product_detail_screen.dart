import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'showStoreDetailsScreen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailScreen({required this.product});

  void _navigateToStoreDetails(BuildContext context) async {
    final storeId = product['storeId'];

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Store details not found.')),
        );
      }
    } else {
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: product['imageUrl1'] != null
                          ? NetworkImage(product['imageUrl1'])
                          : AssetImage('assets/default_product.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.blue.shade50,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Product Name
              Text(
                product['name'] ?? 'Product Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 10),
              // Product details
              _buildInfoRow(
                icon: Icons.category,
                label: 'Type',
                value: product['productType'] ?? '-',
              ),
              _buildInfoRow(
                icon: Icons.price_check,
                label: 'Price',
                value: '₹${product['price'] ?? 'N/A'}',
              ),
              _buildInfoRow(
                icon: Icons.check_circle_outline,
                label: 'Available',
                value: product['isAvailable'] == true ? 'Yes' : 'No',
              ),
              _buildInfoRow(
                icon: Icons.description,
                label: 'Description',
                value: product['description'] ?? '-',
              ),
              SizedBox(height: 30),
              // About Store button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToStoreDetails(context),
                  icon: Icon(Icons.store),
                  label: Text('About Store'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
