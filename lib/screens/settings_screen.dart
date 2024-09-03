import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('View/Edit Profile'),
              onTap: () async {
                // Determine the user's role and navigate to the appropriate profile screen
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Check if the user is a customer or store owner
                  DocumentSnapshot customerDoc = await FirebaseFirestore
                      .instance
                      .collection('customers')
                      .doc(user.uid)
                      .get();
                  DocumentSnapshot storeOwnerDoc = await FirebaseFirestore
                      .instance
                      .collection('storeOwners')
                      .doc(user.uid)
                      .get();

                  if (customerDoc.exists) {
                    // Navigate to customer profile view/edit screen
                    Navigator.pushNamed(context, '/customerProfile');
                  } else if (storeOwnerDoc.exists) {
                    // Navigate to store owner profile view/edit screen
                    Navigator.pushNamed(context, '/storeOwnerProfile');
                  } else {
                    // Handle case where user role is undefined
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User role is undefined.')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/roleSelection');
              },
            ),
          ],
        ),
      ),
    );
  }
}
