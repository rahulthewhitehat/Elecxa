import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signup_screen.dart'; // Import the SignUpScreen
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isPasswordVisible = false;

  void _loginWithEmail() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _checkRoleConsistency(userCredential.user);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An unexpected error occurred. Please try again.';
      if (e.code == 'wrong-password')
        errorMessage = 'Wrong password. Try again.';
      if (e.code == 'user-not-found')
        errorMessage = 'No user found for this email.';
      if (e.code == 'invalid-email')
        errorMessage = 'The email address is badly formatted.';
      if (e.code == 'user-disabled')
        errorMessage = 'This user has been disabled.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

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

      await _checkRoleConsistency(userCredential.user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log in with Google.')),
      );
    }
  }

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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', widget.role);

      final userDoc = await FirebaseFirestore.instance
          .collection(widget.role == 'customer' ? 'customers' : 'storeOwners')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Navigator.pushReplacementNamed(
            context,
            widget.role == 'customer'
                ? '/customerDashboard'
                : '/storeOwnerDashboard');
      } else {
        Navigator.pushReplacementNamed(
            context,
            widget.role == 'customer'
                ? '/customerDetails'
                : '/storeOwnerDetails');
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loginWithEmail,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Login with Email',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _forgotPassword,
                    child: Text('Forgot Password?',
                        style: TextStyle(color: Colors.blue.shade700)),
                  ),
                  TextButton(
                    onPressed: _navigateToSignUpScreen,
                    child: Text('Register Here',
                        style: TextStyle(color: Colors.blue.shade700)),
                  ),
                  SizedBox(height: 40),
                  Text('or', style: TextStyle(color: Colors.grey.shade600)),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _loginWithGoogle,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                          'assets/google_logo.png'), // Path to your asset image
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
