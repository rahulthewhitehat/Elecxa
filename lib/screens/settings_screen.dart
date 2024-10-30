import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatelessWidget {
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(
                color: Colors.blue.shade700, fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('No', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/roleSelection');
              },
            ),
          ],
        );
      },
    );
  }

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
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.blue.shade700),
                title: Text(
                  'View/Edit Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
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
                      Navigator.pushNamed(context, '/customerProfile');
                    } else if (storeOwnerDoc.exists) {
                      Navigator.pushNamed(context, '/storeOwnerProfile');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User role is undefined.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () {
                  _showLogoutConfirmation(context); // Show confirmation dialog
                },
              ),
            ),
            Spacer(),
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue.shade700),
                title: Text(
                  'About',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () {
                  Navigator.pushNamed(
                      context, '/about'); // Navigate to the About page
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
