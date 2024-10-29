import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  final String role; // 'customer' or 'storeOwner'
  SignUpScreen({required this.role});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _signUpWithEmail() async {
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check for role consistency
      await _checkRoleConsistency(userCredential.user);
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already in use.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is badly formatted.';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // Check if the user role is consistent with their registration role
  Future<void> _checkRoleConsistency(User? user) async {
    if (user != null) {
      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .get();
      final storeOwnerDoc = await FirebaseFirestore.instance
          .collection('storeOwners')
          .doc(user.uid)
          .get();

      if (widget.role == 'customer' && storeOwnerDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('This email is already registered as a store owner.')),
        );
        _auth.signOut();
        return;
      } else if (widget.role == 'storeOwner' && customerDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('This email is already registered as a customer.')),
        );
        _auth.signOut();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed up successfully!')),
      );
      _navigateToDetailsOrDashboard(user);
    }
  }

  void _navigateToDetailsOrDashboard(User? user) async {
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', widget.role);

      final userDoc = await FirebaseFirestore.instance
          .collection(widget.role == 'customer' ? 'customers' : 'storeOwners')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        if (widget.role == 'customer') {
          Navigator.pushReplacementNamed(context, '/customerDashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/storeOwnerDashboard');
        }
      } else {
        if (widget.role == 'customer') {
          Navigator.pushReplacementNamed(context, '/customerDetails');
        } else {
          Navigator.pushReplacementNamed(context, '/storeOwnerDetails');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Sign Up as ${widget.role == 'customer' ? 'Customer' : 'Store Owner'}'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.blue.shade700,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.blue.shade700,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _signUpWithEmail,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blue, // Set the button color to blue
                ),
                child: Text(
                  'Sign Up with Email',
                  style: TextStyle(
                      fontSize: 16, color: Colors.white), // White text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
