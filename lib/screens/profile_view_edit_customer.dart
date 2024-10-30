import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CustomerProfileViewEditScreen extends StatefulWidget {
  @override
  _CustomerProfileViewEditScreenState createState() =>
      _CustomerProfileViewEditScreenState();
}

class _CustomerProfileViewEditScreenState
    extends State<CustomerProfileViewEditScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? _imageUrl;
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('customers').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _nameController.text = data['name'] ?? '';
          _phoneNumberController.text = data['phoneNumber'] ?? '';
          _locationController.text = data['location'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _imageUrl = data['profileImageUrl'];
          _isLoading = false;
        });
      }
    }
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? imageUrl;
        if (_profileImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child(user.uid + '.jpg');
          await ref.putFile(_profileImage!);
          imageUrl = await ref.getDownloadURL();
        } else {
          imageUrl = _imageUrl;
        }

        await _firestore.collection('customers').doc(user.uid).update({
          'username': _usernameController.text.trim(),
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'location': _locationController.text.trim(),
          'bio': _bioController.text.trim(),
          'profileImageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Profile'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : _imageUrl != null
                                ? NetworkImage(_imageUrl!)
                                : AssetImage('assets/default_profile.png')
                                    as ImageProvider,
                        backgroundColor: Colors.blue.shade50,
                        child: _profileImage == null && _imageUrl == null
                            ? Icon(Icons.add_a_photo,
                                size: 40, color: Colors.blue)
                            : null,
                      ),
                    ),
                    SizedBox(height: 25),
                    _buildTextField(
                        controller: _usernameController, label: 'Username'),
                    _buildTextField(controller: _nameController, label: 'Name'),
                    _buildTextField(
                        controller: _phoneNumberController,
                        label: 'Phone Number'),
                    _buildTextField(
                        controller: _locationController, label: 'Location'),
                    _buildTextField(
                        controller: _bioController, label: 'Bio (optional)'),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Save Changes',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ),
    );
  }
}
