import 'package:elecxa/screens/profile_view_edit_store_owner.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'store_location_picker_screen.dart'; // Import the location picker screen

class StoreOwnerDetailsScreen extends StatefulWidget {
  @override
  _StoreOwnerDetailsScreenState createState() =>
      _StoreOwnerDetailsScreenState();
}

class _StoreOwnerDetailsScreenState extends State<StoreOwnerDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _storeNameController = TextEditingController();
  List<String> _storeTypes = [];
  LatLng? _storeLocation; // Store location as LatLng
  Map<String, Map<String, String>> _storeHours = {};
  final _websiteController = TextEditingController();
  final _storeDescriptionController = TextEditingController();

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _selectStoreType() async {
    final List<String> options = [
      'Electronic Store',
      'Hardware Store',
      'Plumbing Store'
    ];
    final List<String>? selectedTypes = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return MultiSelectDialog(
          options: options,
          selectedOptions: _storeTypes,
        );
      },
    );
    if (selectedTypes != null) {
      setState(() {
        _storeTypes = selectedTypes;
      });
    }
  }

  void _selectStoreHours() async {
    final Map<String, Map<String, String>>? storeHours =
        await showDialog<Map<String, Map<String, String>>>(
      context: context,
      builder: (context) {
        return StoreHoursDialog(currentStoreHours: _storeHours);
      },
    );
    if (storeHours != null) {
      setState(() {
        _storeHours = storeHours;
      });
    }
  }

  void _pickStoreLocation() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoreLocationPickerScreen()),
    );
    if (selectedLocation != null) {
      setState(() {
        _storeLocation = selectedLocation;
      });
    }
  }

  void _saveStoreOwnerDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId =
            user.uid; // Use the authenticated user's UID as the store ID

        String? imageUrl;
        if (_profileImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('store_owner_images')
              .child(userId + '.jpg');
          await ref.putFile(_profileImage!);
          imageUrl = await ref.getDownloadURL();
        }

        // Ensure all the fields are not null before saving
        if (_storeNameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Store name is required')),
          );
          return;
        }

        if (_storeLocation == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select store location')),
          );
          return;
        }

        // Set store details in Firestore using the authenticated user's UID as the document ID
        await _firestore.collection('storeOwners').doc(userId).set({
          'storeId': userId, // Explicitly save the storeId using userId
          'username': _usernameController.text.trim(),
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'email': user.email,
          'storeName': _storeNameController.text.trim(),
          'storeType': _storeTypes,
          'storeLocation': {
            'latitude': _storeLocation?.latitude,
            'longitude': _storeLocation?.longitude,
          },
          'storeHours': _storeHours,
          'website': _websiteController.text.trim(),
          'storeDescription': _storeDescriptionController.text.trim(),
          'profileImageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Account creation successful! Details saved.')),
        );

        Navigator.pushReplacementNamed(context, '/storeOwnerDashboard');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save details. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Owner Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: _storeNameController,
                decoration: InputDecoration(labelText: 'Store Name'),
              ),
              TextButton(
                onPressed: _pickStoreLocation,
                child: Text('Select Store Location'),
              ),
              Text(_storeLocation == null
                  ? 'No location selected'
                  : 'Location selected: (${_storeLocation!.latitude}, ${_storeLocation!.longitude})'),
              SizedBox(height: 20),
              TextButton(
                onPressed: _selectStoreType,
                child: Text('Select Store Type'),
              ),
              Text(_storeTypes.isEmpty
                  ? 'No store type selected'
                  : _storeTypes.join(', ')),
              SizedBox(height: 20),
              TextButton(
                onPressed: _selectStoreHours,
                child: Text('Set Store Hours'),
              ),
              Text(_storeHours.isEmpty
                  ? 'No hours set'
                  : 'Store hours set for some days'),
              TextField(
                controller: _websiteController,
                decoration: InputDecoration(labelText: 'Website (optional)'),
              ),
              TextField(
                controller: _storeDescriptionController,
                decoration:
                    InputDecoration(labelText: 'Store Description (optional)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveStoreOwnerDetails,
                child: Text('Save Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
