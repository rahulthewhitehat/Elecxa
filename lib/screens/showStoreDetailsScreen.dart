import 'package:flutter/material.dart';
import 'store_location_view_screen.dart'; // Import the new screen to view store location
import 'package:geocoding/geocoding.dart'; // Import geocoding package for address lookup

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
                  // Dummy contact button action
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
