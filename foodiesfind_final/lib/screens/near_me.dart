import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({Key? key}) : super(key: key);

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  final Location _locationService = Location();
  bool _isLoading = true;

  // final List<Marker> _restaurantMarkers = [
  //   Marker(
  //     markerId: MarkerId('restaurant1'),
  //     position: LatLng(5.3331, 100.3064),
  //     infoWindow: InfoWindow(title: 'ABC Cafe', snippet: 'Open 9 AM - 9 PM'),
  //   ),
  //   Marker(
  //     markerId: MarkerId('restaurant2'),
  //     position: LatLng(5.3345, 100.3102),
  //     infoWindow: InfoWindow(
  //       title: 'Seafood Delight',
  //       snippet: 'Open 11:30 AM – 9:30 PM',
  //     ),
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool _serviceEnabled = await _locationService.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _locationService.requestService();
        if (!_serviceEnabled) return;
      }

      PermissionStatus _permissionGranted =
          await _locationService.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _locationService.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) return;
      }

      final locationData = await _locationService.getLocation();

      setState(() {
        _currentLocation = locationData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() => _isLoading = false); // prevent infinite loader
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Near Me"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // ← fixes weird overlay
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentLocation == null
              ? const Center(child: Text('Location unavailable.'))
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!,
                  ),
                  zoom: 15,
                ),
                //markers: Set<Marker>.of(_restaurantMarkers),
                //myLocationEnabled: true,
                //myLocationButtonEnabled: true,
                onMapCreated: (controller) => _mapController = controller,
              ),
    );
  }
}
