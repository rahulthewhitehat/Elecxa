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
    List<DocumentSnapshot> filteredStores = _stores.where((store) {
      final storeData = store.data() as Map<String, dynamic>;
      final storeName = storeData['storeName']?.toLowerCase() ?? '';
      final storeType =
          (storeData['storeType'] as List?)?.join(', ').toLowerCase() ?? '';
      final location = storeData['storeLocation']?['city']?.toLowerCase() ?? '';
      return storeName.contains(_searchQuery) ||
          storeType.contains(_searchQuery) ||
          location.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Stores', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue.shade700,
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search by store name, type, or location',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                suffixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchStores,
            ),
          ),
          Expanded(
            child: filteredStores.isEmpty
                ? Center(
                    child: Text('No stores found',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: filteredStores.length,
                    itemBuilder: (context, index) {
                      final store =
                          filteredStores[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: store['profileImageUrl'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    store['profileImageUrl'],
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
                                  child: Icon(Icons.store,
                                      size: 40, color: Colors.blue.shade700),
                                ),
                          title: Text(
                            store['storeName'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          subtitle: Text(
                            (store['storeType'] is List)
                                ? (store['storeType'] as List).join(', ')
                                : (store['storeType'] ?? ''),
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
                                    ShowStoreDetailsScreen(store: store),
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
