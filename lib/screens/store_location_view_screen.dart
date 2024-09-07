import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoreLocationViewScreen extends StatelessWidget {
  final Map<String, dynamic>? location;

  StoreLocationViewScreen({required this.location});

  @override
  Widget build(BuildContext context) {
    LatLng storeLocation;
    if (location != null &&
        location!['latitude'] != null &&
        location!['longitude'] != null) {
      storeLocation = LatLng(location!['latitude'], location!['longitude']);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Store Location'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Text('No location available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Store Location'),
        backgroundColor: Colors.blue,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: storeLocation,
          zoom: 15, // Adjust zoom level as necessary
        ),
        markers: {
          Marker(
            markerId: MarkerId('store-location'),
            position: storeLocation,
          ),
        },
      ),
    );
  }
}
