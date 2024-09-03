import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_selection_screen.dart';
import 'package:elecxa/dashboards/customer_dashboard.dart'; // Import the customer dashboard screen
import 'package:elecxa/dashboards/store_owner_dashboard.dart'; // Import the store owner dashboard screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false; // Flag to prevent multiple navigations

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      // Increase the delay to 5 seconds
      _checkAuthentication();
    });
  }

  Future<void> _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('user_role');

    // Guard clause to prevent multiple navigations
    if (_isNavigating) return;
    _isNavigating = true;

    if (user != null && role != null) {
      // User is logged in and role is available
      if (role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerDashboard()),
        );
      } else if (role == 'storeOwner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StoreOwnerDashboard()),
        );
      }
    } else {
      // No user logged in or role not set
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 300),
            SizedBox(height: 20),
            Text(
              'Elecxa',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
