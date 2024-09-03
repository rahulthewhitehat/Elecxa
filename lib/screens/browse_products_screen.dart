import 'dart:async';
import 'package:elecxa/screens/showStoreDetailsScreen.dart'; // Import the ShowStoreDetailsScreen
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart'; // Import the ProductDetailScreen

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
    if (_productSubscription != null) {
      _productSubscription!.cancel();
    }

    // Real-time, case-insensitive search
    _productSubscription = _firestore
        .collectionGroup('products')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _products = snapshot.docs.where((doc) {
          final productName = (doc['name'] ?? '').toString().toLowerCase();
          final productType =
              (doc['productType'] ?? '').toString().toLowerCase();
          return productName.contains(_searchQuery) &&
              (_selectedType == 'All' ||
                  productType == _selectedType.toLowerCase());
        }).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    // Initialize subscription to fetch products with real-time updates
    _searchProducts(''); // Trigger initial fetch with empty query
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
        title: Text('Browse Products'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by product name',
                    ),
                    onChanged: _searchProducts,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchProducts(
                      _searchQuery), // Updated to trigger search
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedType,
              items: ['All', 'Electronics', 'Hardware', 'Plumbing Materials']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
                _searchProducts(_searchQuery);
              },
              hint: Text('Filter by Type'),
            ),
          ),
          Expanded(
            child: _products.isEmpty
                ? Center(child: Text('No products found'))
                : ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product =
                          _products[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: product['imageUrl1'] != null
                            ? Image.network(product['imageUrl1'],
                                width: 50, height: 50)
                            : null,
                        title: Text(product['name'] ?? ''),
                        subtitle: Text(
                            '₹${product['price']} - ${product['isAvailable'] ? 'Available' : 'Unavailable'}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
