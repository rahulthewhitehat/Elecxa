import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'store_location_view_screen.dart'; // Import the new screen to view store location
import 'chat_screen.dart'; // Import the chat screen to handle messages
import 'package:geocoding/geocoding.dart'; // Import geocoding package for address lookup
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // Import for hash generation

class ShowStoreDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> store;

  ShowStoreDetailsScreen({required this.store});

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
    return 'No location available';
  }

  String _generateChatId(String customerId, String storeId) {
    // Generate a consistent chat ID by hashing the customerId and storeId
    List<String> ids = [customerId, storeId];
    ids.sort(); // Ensure the order is consistent regardless of who starts the chat
    return base64UrlEncode(utf8.encode(ids.join("_"))); // Create a hashed ID
  }

  void _openChatScreen(
      BuildContext context, String storeId, String storeName) async {
    String customerId = FirebaseAuth.instance.currentUser!.uid;

    // Ensure that storeId is valid and not empty
    if (storeId == null || storeId.isEmpty || storeId == 'Unknown Store ID') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Invalid store ID. Please try again.')),
      );
      return;
    }

    // Fetch customer name from Firestore
    DocumentSnapshot customerDoc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .get();
    String customerName = customerDoc['name'] ?? 'Unknown Customer';

    // Generate a unique and consistent chat ID
    String chatId = _generateChatId(customerId, storeId);

    // Check if a chat already exists between the customer and the store
    DocumentSnapshot chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      // Create a new chat document if it doesn't exist
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'participants': [customerId, storeId],
        'storeId': storeId,
        'storeName': storeName,
        'customerName': customerName,
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          storeId: storeId,
          storeName: storeName,
          customerName: customerName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? storeId = store['storeId'];
    if (storeId == null || storeId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Invalid Store'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Text('Store details not available. Please try again.'),
        ),
      );
    }

    String storeName = store['storeName'] ?? 'Unknown Store';

    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store profile image (larger size)
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: store['profileImageUrl'] != null
                          ? NetworkImage(store['profileImageUrl'])
                          : AssetImage('assets/default_store.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.blue.shade50,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Store Name
              Text(
                storeName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 10),
              // Store type
              _buildInfoRow(
                icon: Icons.category,
                label: 'Type',
                value: (store['storeType'] is List)
                    ? (store['storeType'] as List).join(', ')
                    : (store['storeType'] ?? '-'),
              ),
              // Store location
              FutureBuilder<String>(
                future: _getAddressFromCoordinates(
                  store['storeLocation']['latitude'] ?? 0.0,
                  store['storeLocation']['longitude'] ?? 0.0,
                ),
                builder: (context, snapshot) {
                  return _buildInfoRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: snapshot.connectionState == ConnectionState.waiting
                        ? 'Fetching location...'
                        : snapshot.data ?? 'No location available',
                  );
                },
              ),
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Phone Number',
                value: store['phoneNumber'] ?? '-',
              ),
              _buildInfoRow(
                icon: Icons.web,
                label: 'Website',
                value: store['website'] ?? '-',
              ),
              _buildInfoRow(
                icon: Icons.description,
                label: 'Description',
                value: store['storeDescription'] ?? '-',
              ),
              SizedBox(height: 20),
              // Store hours section with enhanced UI
              Text(
                'Store Hours:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildStoreHours(store['storeHours']),
              SizedBox(height: 20),
              // Contact and Location buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _openChatScreen(context, storeId, storeName);
                    },
                    icon: Icon(Icons.message),
                    label: Text('Contact Store'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreLocationViewScreen(
                            location: store['storeLocation'],
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.map),
                    label: Text('View Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHours(Map<String, dynamic>? storeHours) {
    if (storeHours == null || storeHours.isEmpty) {
      return Text('No hours set', style: TextStyle(fontSize: 16));
    }

    // Define the ordered days of the week
    final List<String> daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    // Filter and display the store hours in order
    return Column(
      children:
          daysOfWeek.where((day) => storeHours.containsKey(day)).map((day) {
        final hours = storeHours[day];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700),
              ),
              Text(
                '${hours['start']} - ${hours['end']}',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
