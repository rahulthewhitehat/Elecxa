import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart';

class BrowseProductsScreen extends StatefulWidget {
  @override
  _BrowseProductsScreenState createState() => _BrowseProductsScreenState();
}

class _BrowseProductsScreenState extends State<BrowseProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedType = 'All';
  List<DocumentSnapshot> _products = [];
  StreamSubscription? _productSubscription;

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    _fetchFilteredProducts();
  }

  void _fetchFilteredProducts() {
    _productSubscription?.cancel();

    _productSubscription = _firestore
        .collectionGroup('products')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _products = snapshot.docs.where((doc) {
          final productData = doc.data() as Map<String, dynamic>;
          final productName =
              (productData['name'] ?? '').toString().toLowerCase();
          final productType =
              (productData['productType'] ?? '').toString().toLowerCase();
          final matchesSearch = productName.contains(_searchQuery);
          final matchesType = _selectedType == 'All' ||
              productType == _selectedType.toLowerCase();
          return matchesSearch && matchesType;
        }).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFilteredProducts();
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Products', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue.shade700,
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search by product name',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _searchProducts,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () => _searchProducts(_searchQuery),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue.shade50,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              value: _selectedType,
              items: ['All', 'Electronics', 'Hardware', 'Plumbing Materials']
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
                _fetchFilteredProducts();
              },
              hint: Text('Filter by Type'),
            ),
          ),
          Expanded(
            child: _products.isEmpty
                ? Center(
                    child: Text(
                      'No products found',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product =
                          _products[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: product['imageUrl1'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product['imageUrl1'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.blue.shade700),
                                ),
                          title: Text(
                            product['name'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          subtitle: Text(
                            '₹${product['price']} - ${product['isAvailable'] ? 'Available' : 'Unavailable'}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade700),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.blue.shade700),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
