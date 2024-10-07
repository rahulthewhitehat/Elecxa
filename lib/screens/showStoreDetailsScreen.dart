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
    // Ensure that we are correctly retrieving the storeId from the store data.
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store['profileImageUrl'] != null)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(store['profileImageUrl']),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              SizedBox(height: 10),
              Text('Store Name: $storeName', style: TextStyle(fontSize: 18)),
              Text(
                'Type: ${(store['storeType'] is List) ? (store['storeType'] as List).join(', ') : (store['storeType'] ?? '-')}',
                style: TextStyle(fontSize: 18),
              ),
              FutureBuilder<String>(
                future: _getAddressFromCoordinates(
                  store['storeLocation']['latitude'] ?? 0.0,
                  store['storeLocation']['longitude'] ?? 0.0,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Fetching location...',
                        style: TextStyle(fontSize: 18));
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return Text('No location available',
                        style: TextStyle(fontSize: 18));
                  } else {
                    return Text('Location: ${snapshot.data}',
                        style: TextStyle(fontSize: 18));
                  }
                },
              ),
              Text('Phone Number: ${store['phoneNumber'] ?? '-'}',
                  style: TextStyle(fontSize: 18)),
              Text('Website: ${store['website'] ?? '-'}',
                  style: TextStyle(fontSize: 18)),
              Text('Description: ${store['storeDescription'] ?? '-'}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Store Hours:', style: TextStyle(fontSize: 18)),
              ..._buildStoreHours(store['storeHours']),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _openChatScreen(context, storeId, storeName);
                },
                child: Text('Contact Store'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
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
                child: Text('View Store Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStoreHours(Map<String, dynamic>? storeHours) {
    if (storeHours == null || storeHours.isEmpty) {
      return [Text('No hours set', style: TextStyle(fontSize: 16))];
    }
    List<Widget> hoursWidgets = [];
    storeHours.forEach((day, hours) {
      hoursWidgets.add(
        Text('$day: ${hours['start']} to ${hours['end']}',
            style: TextStyle(fontSize: 16)),
      );
    });
    return hoursWidgets;
  }
}
