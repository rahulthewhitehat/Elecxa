import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDashboard extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('customers').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Dashboard'),
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching user data."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("User data not found."));
          }

          final userData = snapshot.data!;
          final userName = userData['name'] ?? 'User';
          final userRole = userData['role'] ?? 'Customer';
          final userImageUrl = userData['profileImageUrl'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile and welcome message
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: userImageUrl != null
                          ? NetworkImage(userImageUrl)
                          : AssetImage('assets/default_profile.png')
                              as ImageProvider,
                      backgroundColor: Colors.blue.shade50,
                      child: userImageUrl == null
                          ? Icon(Icons.person, size: 30, color: Colors.blue)
                          : null,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $userName',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        Text(
                          'Role: $userRole',
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
                    children: [
                      _buildDashboardButton(
                        context,
                        icon: Icons.storefront,
                        label: 'Browse Stores',
                        onPressed: () {
                          Navigator.pushNamed(context, '/browseStores');
                        },
                      ),
                      _buildDashboardButton(
                        context,
                        icon: Icons.shopping_bag,
                        label: 'Browse Products',
                        onPressed: () {
                          Navigator.pushNamed(context, '/browseProducts');
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
        padding: EdgeInsets.all(16.0),
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
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }
}
