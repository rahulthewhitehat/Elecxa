import 'package:flutter/material.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Role'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to Customer Login
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen(role: 'customer')),
                );
              },
              child: Text('Login as Customer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Store Owner Login
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen(role: 'storeOwner')),
                );
              },
              child: Text('Login as Store Owner'),
            ),
          ],
        ),
      ),
    );
  }
}
