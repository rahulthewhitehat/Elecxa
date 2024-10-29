import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class StoreLocationPickerScreen extends StatefulWidget {
  @override
  _StoreLocationPickerScreenState createState() =>
      _StoreLocationPickerScreenState();
}

class _StoreLocationPickerScreenState extends State<StoreLocationPickerScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  TextEditingController _searchController = TextEditingController();
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  void _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() {
        _locationEnabled = true;
      });
      _getCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission is required')),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _getCurrentLocation();
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _saveLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location.')),
      );
    }
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isNotEmpty) {
      try {
        List<Location> locations =
            await locationFromAddress(_searchController.text);
        if (locations.isNotEmpty) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(locations.first.latitude, locations.first.longitude),
            ),
          );
          setState(() {
            _selectedLocation =
                LatLng(locations.first.latitude, locations.first.longitude);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location not found')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationEnabled) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 15),
      );
      setState(() {
        _selectedLocation = currentLocation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get current location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Store Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 4.0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _searchLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.blue),
                  onPressed: _searchLocation,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(13.0827, 80.2707),
                zoom: 10,
              ),
              onMapCreated: _onMapCreated,
              onTap: _onTap,
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId('selected-location'),
                        position: _selectedLocation!,
                        infoWindow: InfoWindow(title: 'Selected Location'),
                      ),
                    }
                  : {},
              myLocationEnabled: _locationEnabled,
              myLocationButtonEnabled: _locationEnabled,
              zoomControlsEnabled: true,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _saveLocation,
        backgroundColor: Colors.green,
        child: Icon(Icons.check, color: Colors.white),
        heroTag: 'save_location',
      ),
    );
  }
}
