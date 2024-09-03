import 'package:flutter/material.dart';

class StoreOwnerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Owner Dashboard'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Disables the back button
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Store Owner Dashboard'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/productManagement');
              },
              child: Text('Manage Products'),
            ),
          ],
        ),
      ),
    );
  }
}
