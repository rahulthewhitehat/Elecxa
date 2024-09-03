import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUpWithEmail,
              child: Text('Sign Up with Email'),
            ),
          ],
        ),
      ),
    );
  }
}
