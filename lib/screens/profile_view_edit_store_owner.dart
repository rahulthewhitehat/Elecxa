import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'store_location_picker_screen.dart';

class StoreOwnerProfileViewEditScreen extends StatefulWidget {
  @override
  _StoreOwnerProfileViewEditScreenState createState() =>
      _StoreOwnerProfileViewEditScreenState();
}

class MultiSelectDialog extends StatefulWidget {
  final List<String> options;
  final List<String> selectedOptions;

  MultiSelectDialog({required this.options, required this.selectedOptions});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  List<String> _tempSelectedOptions = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedOptions = widget.selectedOptions;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Store Type'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.options.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: _tempSelectedOptions.contains(option),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _tempSelectedOptions.add(option);
                  } else {
                    _tempSelectedOptions.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, _tempSelectedOptions);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class StoreHoursDialog extends StatefulWidget {
  final Map<String, Map<String, String>> currentStoreHours;

  StoreHoursDialog({required this.currentStoreHours});

  @override
  _StoreHoursDialogState createState() => _StoreHoursDialogState();
}

class _StoreHoursDialogState extends State<StoreHoursDialog> {
  Map<String, Map<String, String>> _storeHours = {};
  List<String> _availableDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    _storeHours = Map.from(widget.currentStoreHours);
    _storeHours.keys.forEach((day) {
      _availableDays.remove(day);
    });
  }

  void _addStoreHour() {
    if (_availableDays.isNotEmpty) {
      setState(() {
        String newDay = _availableDays.first;
        _storeHours[newDay] = {
          'start': '09:00 AM',
          'end': '05:00 PM',
        };
        _availableDays.remove(newDay);
      });
    }
  }

  void _removeStoreHour(String day) {
    setState(() {
      _storeHours.remove(day);
      _availableDays.add(day);
      _availableDays.sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Store Hours'),
      content: SingleChildScrollView(
        child: Column(
          children: _storeHours.keys.map((day) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: day,
                    items: [DropdownMenuItem(value: day, child: Text(day))]
                        .followedBy(
                      _availableDays.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }),
                    ).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != day) {
                        setState(() {
                          _storeHours[newValue] = _storeHours.remove(day)!;
                          _availableDays.add(day);
                          _availableDays.remove(newValue);
                          _availableDays.sort();
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _storeHours[day]!['start'] =
                              pickedTime.format(context);
                        });
                      }
                    },
                    child: Text(_storeHours[day]!['start'] ?? 'Start Time'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _storeHours[day]!['end'] = pickedTime.format(context);
                        });
                      }
                    },
                    child: Text(_storeHours[day]!['end'] ?? 'End Time'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _removeStoreHour(day);
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _addStoreHour,
          child: Text('Add Day'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _storeHours);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class _StoreOwnerProfileViewEditScreenState
    extends State<StoreOwnerProfileViewEditScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? _imageUrl;
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _storeNameController = TextEditingController();
  List<String> _storeTypes = [];
  Map<String, Map<String, String>> _storeHours = {};
  final _websiteController = TextEditingController();
  final _storeDescriptionController = TextEditingController();

  LatLng? _selectedLocation;
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
          await _firestore.collection('storeOwners').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _nameController.text = data['name'] ?? '';
          _phoneNumberController.text = data['phoneNumber'] ?? '';
          _storeNameController.text = data['storeName'] ?? '';
          _storeTypes = List<String>.from(data['storeType'] ?? []);
          _storeHours = (data['storeHours'] as Map<String, dynamic>?)
                  ?.map((key, value) {
                return MapEntry(key, Map<String, String>.from(value as Map));
              }) ??
              {};

          if (data['storeLocation'] is Map<String, dynamic>) {
            Map<String, dynamic> locationData = data['storeLocation'];
            if (locationData.containsKey('latitude') &&
                locationData.containsKey('longitude')) {
              _selectedLocation = LatLng(
                locationData['latitude'].toDouble(),
                locationData['longitude'].toDouble(),
              );
            }
          }

          _websiteController.text = data['website'] ?? '';
          _storeDescriptionController.text = data['storeDescription'] ?? '';
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

  void _selectStoreLocation() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoreLocationPickerScreen()),
    );
    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
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
              .child('store_owner_images')
              .child(user.uid + '.jpg');
          await ref.putFile(_profileImage!);
          imageUrl = await ref.getDownloadURL();
        } else {
          imageUrl = _imageUrl;
        }

        Map<String, dynamic>? storeLocation;
        if (_selectedLocation != null) {
          storeLocation = {
            'latitude': _selectedLocation!.latitude,
            'longitude': _selectedLocation!.longitude,
          };
        }

        await _firestore.collection('storeOwners').doc(user.uid).update({
          'username': _usernameController.text.trim(),
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'storeName': _storeNameController.text.trim(),
          'storeType': _storeTypes,
          'storeHours': _storeHours,
          'storeLocation': storeLocation,
          'website': _websiteController.text.trim(),
          'storeDescription': _storeDescriptionController.text.trim(),
          'profileImageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Owner Profile'),
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
                        controller: _storeNameController, label: 'Store Name'),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: _selectStoreLocation,
                      child: Text('Select Store Location',
                          style: TextStyle(color: Colors.blue.shade700)),
                    ),
                    Text(
                      _selectedLocation == null
                          ? 'No location selected'
                          : 'Location: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 15),
                    TextButton(
                      onPressed: _selectStoreType,
                      child: Text('Select Store Type',
                          style: TextStyle(color: Colors.blue.shade700)),
                    ),
                    Text(
                      _storeTypes.isEmpty
                          ? 'No store type selected'
                          : _storeTypes.join(', '),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 15),
                    TextButton(
                      onPressed: _selectStoreHours,
                      child: Text('Set Store Hours',
                          style: TextStyle(color: Colors.blue.shade700)),
                    ),
                    Text(
                      _storeHours.isEmpty
                          ? 'No hours set'
                          : 'Store hours set for some days',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 15),
                    _buildTextField(
                        controller: _websiteController,
                        label: 'Website (optional)'),
                    _buildTextField(
                        controller: _storeDescriptionController,
                        label: 'Store Description (optional)'),
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
