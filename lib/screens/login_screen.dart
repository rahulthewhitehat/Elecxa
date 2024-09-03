import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signup_screen.dart'; // Import the SignUpScreen

class LoginScreen extends StatefulWidget {
  final String role; // 'customer' or 'storeOwner'
  LoginScreen({required this.role});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Email/Password Login
  void _loginWithEmail() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check for role consistency
      await _checkRoleConsistency(userCredential.user);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Wrong password. Try again.';
      if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password. Try again.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for this email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user has been disabled.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An unexpected error occurred. Please try again.')),
      );
    }
  }

  // Google Login
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null) return;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check for role consistency
      await _checkRoleConsistency(userCredential.user);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log in with Google.')),
      );
    }
  }

  // Check if the user role is consistent with their login role
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
        SnackBar(content: Text('Logged in successfully!')),
      );
      _navigateToDetailsOrDashboard(user);
    }
  }

  // Forgot Password
  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password'),
        content: TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Enter your email'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await _auth.sendPasswordResetEmail(
                    email: _emailController.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password reset email sent!')),
                );
              } catch (e) {
                print('Error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to send reset email.')),
                );
              }
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
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

  void _navigateToSignUpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen(role: widget.role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Login as ${widget.role == 'customer' ? 'Customer' : 'Store Owner'}'),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithEmail,
              child: Text('Login with Email'),
            ),
            ElevatedButton(
              onPressed: _loginWithGoogle,
              child: Text('Login with Google'),
            ),
            TextButton(
              onPressed: _forgotPassword,
              child: Text('Forgot Password?'),
            ),
            TextButton(
              onPressed: _navigateToSignUpScreen,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
