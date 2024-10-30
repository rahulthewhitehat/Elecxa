import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreOwnerDashboard extends StatefulWidget {
  @override
  _StoreOwnerDashboardState createState() => _StoreOwnerDashboardState();
}

class _StoreOwnerDashboardState extends State<StoreOwnerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String storeOwnerName = "Loading..."; // Placeholder for store owner's name
  String storeName = "Store"; // Placeholder for store name
  String? userImageUrl; // Profile image URL for the store owner
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStoreOwnerData(); // Load store owner data on initialization
  }

  Future<void> _fetchStoreOwnerData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('storeOwners').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            storeOwnerName = data['name'] ?? 'Store Owner';
            storeName = data['storeName'] ?? 'Your Store';
            userImageUrl = data['profileImageUrl']; // Optional, might be null
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching store owner data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Owner Dashboard'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile information display
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: userImageUrl != null
                            ? NetworkImage(userImageUrl!)
                            : AssetImage('assets/default_profile.png')
                                as ImageProvider,
                        backgroundColor: Colors.blue.shade50,
                        child: userImageUrl == null
                            ? Icon(Icons.store, size: 30, color: Colors.blue)
                            : null,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $storeOwnerName',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text(
                            'Store: $storeName',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Dashboard buttons
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      padding: const EdgeInsets.all(8),
                      children: [
                        _buildDashboardButton(
                          context,
                          icon: Icons.inventory,
                          label: 'Manage Products',
                          onPressed: () {
                            Navigator.pushNamed(context, '/productManagement');
                          },
                        ),
                        _buildDashboardButton(
                          context,
                          icon: Icons.message,
                          label: 'Messages',
                          onPressed: () {
                            Navigator.pushNamed(context, '/messages');
                          },
                        ),
                        _buildDashboardButton(
                          context,
                          icon: Icons.notifications,
                          label: 'Requests',
                          onPressed: () {
                            Navigator.pushNamed(context, '/storeOwnerRequests');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(24.0),
        backgroundColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          SizedBox(height: 10),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, color: Colors.blue.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
