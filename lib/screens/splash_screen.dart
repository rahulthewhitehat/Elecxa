import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_selection_screen.dart';
import 'package:elecxa/dashboards/customer_dashboard.dart'; // Import the customer dashboard screen
import 'package:elecxa/dashboards/store_owner_dashboard.dart'; // Import the store owner dashboard screen
import 'package:location/location.dart' as loc; // Alias for location package
import 'package:geolocator/geolocator.dart'; // For geolocation services

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
      // 5-second delay
      _checkAuthentication();
    });
  }

  Future<void> _checkAuthentication() async {
    // Guard clause to prevent multiple navigations
    if (_isNavigating) return;

    // Check authentication state
    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('user_role');

    if (user != null && role != null) {
      setState(() {
        _isNavigating = true;
      });
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
      setState(() {
        _isNavigating = true;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      );
    }

    // Request location permission, but do not block navigation if not granted
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    loc.Location location = loc.Location();
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    if (_permissionGranted == loc.PermissionStatus.granted) {
      Position position = await _getCurrentLocation();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setDouble('latitude', position.latitude);
      prefs.setDouble('longitude', position.longitude);
    }
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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
