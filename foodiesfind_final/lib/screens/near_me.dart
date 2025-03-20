import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../services/google_places_service.dart';
import '../config.dart';

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({Key? key}) : super(key: key);

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  late GooglePlacesService _placesService;
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  final Location _locationService = Location();

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  List<Marker> _markers = [];
  String _currentPlaceName = "";
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _placesService = GooglePlacesService(googleApiKey);
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted =
          await _locationService.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationService.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final locationData = await _locationService.getLocation();
      setState(() {
        _currentLocation = locationData;
        _isLoading = false;
      });

      if (_mapController != null &&
          locationData.latitude != null &&
          locationData.longitude != null) {
        _moveCameraTo(locationData.latitude!, locationData.longitude!);
      }

      final placeName = await _placesService.getCurrentNearbyPlaceName(
        locationData.latitude!,
        locationData.longitude!,
      );

      setState(() {
        _currentPlaceName = placeName ?? "";
      });
    } catch (e) {
      debugPrint('Location error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _moveCameraTo(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15),
      ),
    );
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    try {
      final coords = await _placesService.geocodeAddress(query);
      if (coords != null) {
        _moveCameraTo(coords.latitude, coords.longitude);

        final places = await _placesService.searchPlaces(query);
        if (places.isNotEmpty) {
          // Create markers from the place search results
          setState(() {
            _markers =
                places.map<Marker>((place) {
                  final loc = place['geometry']['location'];
                  return Marker(
                    markerId: MarkerId(place['place_id']),
                    position: LatLng(loc['lat'], loc['lng']),
                    infoWindow: InfoWindow(title: place['name']),
                  );
                }).toList();
          });
        } else {
          // If no places returned, just mark the geocoded location
          setState(() {
            _markers = [
              Marker(
                markerId: const MarkerId('geocode_location'),
                position: coords,
                infoWindow: InfoWindow(title: 'Result: $query'),
              ),
            ];
          });
        }
      }
    } catch (e) {
      debugPrint('Search failed: $e');
    }
  }

  /// Called whenever the user types in the search bar
  void _onTextChanged(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    // Fetch autocomplete suggestions
    final suggestions = await _placesService.getAutocompleteSuggestions(input);

    // Update the UI with suggestions
    setState(() {
      _suggestions = suggestions;
    });
  }

  /// Called when the user taps a suggestion from the dropdown
  void _onSuggestionTap(String suggestion) {
    setState(() {
      _searchController.text = suggestion;
      _suggestions = [];
    });
    // Optionally call the search logic with the selected suggestion
    _searchPlaces(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentLocation == null
              ? const Center(child: Text('Location unavailable'))
              : Stack(
                children: [
                  // The Map
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: Set<Marker>.of(_markers),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_currentLocation != null) {
                        _moveCameraTo(
                          _currentLocation!.latitude!,
                          _currentLocation!.longitude!,
                        );
                      }
                    },
                  ),

                  // The Search Bar + Suggestions
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Back button or menu button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Search Field
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _onTextChanged,
                                  onSubmitted: _searchPlaces,
                                  decoration: const InputDecoration(
                                    hintText: 'Search places...',
                                    border: InputBorder.none,
                                    icon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Suggestions Dropdown
                        if (_suggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 5),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              maxHeight:
                                  300, // Limit max height so it doesn't fill screen
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _suggestions.length,
                              separatorBuilder:
                                  (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final suggestion = _suggestions[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: Text(suggestion),
                                  onTap: () => _onSuggestionTap(suggestion),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
