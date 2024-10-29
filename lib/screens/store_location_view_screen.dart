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
          child: Text(
            'No location available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Store Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 4.0, // Adds a subtle shadow
      ),
      body: Container(
        color: Colors.blue.shade50, // Light background for consistency
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: storeLocation,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId('store-location'),
              position: storeLocation,
              infoWindow: InfoWindow(title: "Store Location"),
            ),
          },
          zoomControlsEnabled: false, // Simplify the map UI
        ),
      ),
    );
  }
}
