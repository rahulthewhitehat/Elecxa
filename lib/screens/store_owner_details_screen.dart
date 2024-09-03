import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  final _storeLocationController = TextEditingController();
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

  // Inside the _saveStoreOwnerDetails() method:
  void _saveStoreOwnerDetails() async {
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
        }

        await _firestore.collection('storeOwners').doc(user.uid).set({
          'username': _usernameController.text.trim(),
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'email': user.email,
          'storeName': _storeNameController.text.trim(),
          'storeType': _storeTypes, // Save selected store types as a list
          'storeLocation': _storeLocationController.text.trim(),
          'storeHours': _storeHours, // Save store hours as a map
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
              TextField(
                controller: _storeLocationController,
                decoration: InputDecoration(labelText: 'Store Location'),
              ),
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
                if (value == true) {
                  setState(() {
                    _tempSelectedOptions.add(option);
                  });
                } else {
                  setState(() {
                    _tempSelectedOptions.remove(option);
                  });
                }
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
                  icon: Icon(Icons.delete, color: Colors.red),
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
