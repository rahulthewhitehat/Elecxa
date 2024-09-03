import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class StoreOwnerProfileViewEditScreen extends StatefulWidget {
  @override
  _StoreOwnerProfileViewEditScreenState createState() =>
      _StoreOwnerProfileViewEditScreenState();
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
  final _storeLocationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _storeDescriptionController = TextEditingController();

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
          _storeHours =
              (data['storeHours'] as Map<String, dynamic>?)?.map((key, value) {
                    return MapEntry(
                      key,
                      Map<String, String>.from(value as Map),
                    );
                  }) ??
                  {};
          _storeLocationController.text = data['storeLocation'] ?? '';
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
          imageUrl = _imageUrl; // Retain existing image URL if no new image
        }

        await _firestore.collection('storeOwners').doc(user.uid).update({
          'username': _usernameController.text.trim(),
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'storeName': _storeNameController.text.trim(),
          'storeType': _storeTypes,
          'storeHours': _storeHours,
          'storeLocation': _storeLocationController.text.trim(),
          'website': _websiteController.text.trim(),
          'storeDescription': _storeDescriptionController.text.trim(),
          'profileImageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : _imageUrl != null
                                ? NetworkImage(_imageUrl!)
                                : AssetImage('assets/default_profile.png')
                                    as ImageProvider, // Default image if none
                        child: _profileImage == null && _imageUrl == null
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
                    TextField(
                      controller: _storeLocationController,
                      decoration: InputDecoration(labelText: 'Store Location'),
                    ),
                    TextButton(
                      onPressed: _selectStoreType,
                      child: Text('Select Store Type'),
                    ),
                    Text(_storeTypes.isEmpty
                        ? 'No store type selected'
                        : _storeTypes.join(', ')),
                    TextButton(
                      onPressed: _selectStoreHours,
                      child: Text('Set Store Hours'),
                    ),
                    Text(_storeHours.isEmpty
                        ? 'No hours set'
                        : 'Store hours set for some days'),
                    TextField(
                      controller: _websiteController,
                      decoration:
                          InputDecoration(labelText: 'Website (optional)'),
                    ),
                    TextField(
                      controller: _storeDescriptionController,
                      decoration: InputDecoration(
                          labelText: 'Store Description (optional)'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Multi-select dialog for store type
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

// Dialog for setting store hours
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
    // Remove already selected days from available days
    _storeHours.keys.forEach((day) {
      _availableDays.remove(day);
    });
  }

  void _addStoreHour() {
    if (_availableDays.isNotEmpty) {
      setState(() {
        String newDay = _availableDays.first; // Pick the first available day
        _storeHours[newDay] = {
          'start': '09:00 AM',
          'end': '05:00 PM',
        };
        _availableDays.remove(newDay); // Remove from available days
      });
    }
  }

  void _removeStoreHour(String day) {
    setState(() {
      _storeHours.remove(day);
      _availableDays.add(day); // Make the day available again
      _availableDays.sort((a, b) => a.compareTo(b)); // Keep days sorted
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
                  flex:
                      3, // Ensures the dropdown takes up a reasonable amount of space
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: day,
                    items: [DropdownMenuItem(value: day, child: Text(day))]
                        .followedBy(
                      _availableDays.map((String value) {
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
                          _availableDays.sort((a, b) => a.compareTo(b));
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
