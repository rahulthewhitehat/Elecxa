import 'package:flutter/material.dart';

class ShowStoreDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> store;

  ShowStoreDetailsScreen({required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(store['storeName'] ?? 'Store Details'),
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
              Text('Store Name: ${store['storeName'] ?? '-'}',
                  style: TextStyle(fontSize: 18)),
              Text(
                  'Type: ${(store['storeType'] is List) ? (store['storeType'] as List).join(', ') : (store['storeType'] ?? '-')}',
                  style: TextStyle(fontSize: 18)),
              Text('Location: ${store['storeLocation'] ?? '-'}',
                  style: TextStyle(fontSize: 18)),
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
                  // Dummy contact button action
                },
                child: Text('Contact Store'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Dummy message button action
                },
                child: Text('Message Store'),
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
