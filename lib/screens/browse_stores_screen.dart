import 'dart:async';

import 'package:elecxa/screens/showStoreDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrowseStoresScreen extends StatefulWidget {
  @override
  _BrowseStoresScreenState createState() => _BrowseStoresScreenState();
}

class _BrowseStoresScreenState extends State<BrowseStoresScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  List<DocumentSnapshot> _stores = [];
  StreamSubscription? _storeSubscription;

  void _searchStores(String query) {
    // Convert the query to lowercase
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    if (_storeSubscription != null) {
      _storeSubscription!.cancel();
    }

    // Fetch all stores and filter by the query in lowercase
    _storeSubscription = _firestore
        .collection('storeOwners')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _stores = snapshot.docs.where((doc) {
          final storeName = (doc['storeName'] ?? '').toString().toLowerCase();
          final storeType = (doc['storeType'] is List)
              ? (doc['storeType'] as List).join(', ').toLowerCase()
              : (doc['storeType'] ?? '').toLowerCase();
          final storeLocation =
              (doc['storeLocation'] ?? '').toString().toLowerCase();
          return storeName.contains(_searchQuery) ||
              storeType.contains(_searchQuery) ||
              storeLocation.contains(_searchQuery);
        }).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  void _fetchStores() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('storeOwners').limit(10).get();
    setState(() {
      _stores = querySnapshot.docs;
    });
  }

  @override
  void dispose() {
    _storeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Stores'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by store name, type, or location',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _searchStores, // Update search query in real-time
            ),
          ),
          Expanded(
            child: _stores.isEmpty
                ? Center(child: Text('No stores found'))
                : ListView.builder(
                    itemCount: _stores.length,
                    itemBuilder: (context, index) {
                      final store =
                          _stores[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: store['profileImageUrl'] != null
                            ? Image.network(store['profileImageUrl'],
                                width: 50, height: 50)
                            : Icon(Icons.store, size: 50),
                        title: Text(store['storeName'] ?? ''),
                        subtitle: Text(
                          (store['storeType'] is List)
                              ? (store['storeType'] as List).join(', ')
                              : (store['storeType'] ?? ''),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShowStoreDetailsScreen(store: store),
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
