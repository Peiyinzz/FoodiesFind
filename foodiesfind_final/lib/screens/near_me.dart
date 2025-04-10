import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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

  Set<Marker> _markers = {};
  List<DocumentSnapshot> _restaurants = [];
  Map<String, double> _distances = {};

  List<String> _suggestions = [];
  DocumentSnapshot? _selectedRestaurant;

  // Polylines for drawing the route on the map
  Map<PolylineId, Polyline> _polylines = {};

  // Track whether we're currently in "directions mode"
  bool _isDirectionsMode = false;

  // To restore the original markers after exiting directions mode
  Set<Marker>? _markersBeforeDirections;

  // Travel info from the Directions API
  String? _travelDistanceText; // e.g. "9.5 km"
  String? _travelDurationText; // e.g. "14 min"
  String? _etaText; // e.g. "03:19"

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
    } catch (e) {
      debugPrint('Location error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRestaurantMarkers({bool onlyNearby = false}) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('restaurants').get();
    final List<Marker> markers = [];
    final List<DocumentSnapshot> nearbyRestaurants = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['loc'] is GeoPoint) {
        final geo = data['loc'] as GeoPoint;
        final lat = geo.latitude;
        final lng = geo.longitude;

        double? distanceKm;
        if (_currentLocation != null) {
          distanceKm = calculateDistance(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
            lat,
            lng,
          );
          _distances[doc.id] = distanceKm;
        }

        // Show markers only if within 5km if onlyNearby == true, otherwise show all
        if (!onlyNearby || (distanceKm != null && distanceKm < 5.0)) {
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              onTap: () {
                final data = doc.data() as Map<String, dynamic>;
                final restaurantName = data['name'] ?? '';
                setState(() {
                  _selectedRestaurant = doc;
                  _searchController.text = restaurantName;
                  // If we were previously in directions mode, exit it
                  _exitDirectionsMode();
                });
              },
            ),
          );
          nearbyRestaurants.add(doc);
        }
      }
    }

    setState(() {
      _restaurants = nearbyRestaurants;
      _markers = markers.toSet();
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void _moveCameraTo(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15),
      ),
    );
  }

  Future<void> _searchRestaurantByName(String input) async {
    if (input.isEmpty) return;

    // Auto-complete: if any suggestion starts with input, use that suggestion as the name
    String completedName = input;
    if (_suggestions.isNotEmpty) {
      final matchingSuggestion = _suggestions.firstWhere(
        (s) => s.toLowerCase().startsWith(input.toLowerCase()),
        orElse: () => input,
      );
      completedName = matchingSuggestion;
      if (completedName.toLowerCase() != input.toLowerCase()) {
        setState(() {
          _searchController.text = completedName;
        });
      }
    }

    final snapshot =
        await FirebaseFirestore.instance.collection('restaurants').get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docName = (data['name'] ?? '').toString().toLowerCase();

      if (docName.contains(completedName.toLowerCase()) &&
          data['loc'] is GeoPoint) {
        final geo = data['loc'] as GeoPoint;
        final lat = geo.latitude;
        final lng = geo.longitude;

        double? distanceKm;
        if (_currentLocation != null) {
          distanceKm = calculateDistance(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
            lat,
            lng,
          );
          _distances[doc.id] = distanceKm;
        }

        // Overwrite markers with just this location
        setState(() {
          _selectedRestaurant = doc;
          _markers = {
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              onTap: () {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name'] ?? '';
                setState(() {
                  _selectedRestaurant = doc;
                  _searchController.text = name;
                  _exitDirectionsMode();
                });
              },
            ),
          };
          _suggestions = [];
        });
        _moveCameraTo(lat, lng);
        break;
      }
    }
  }

  /// Fetch route details from the Directions API, parse distance & duration,
  /// remove all other markers except destination, store original markers,
  /// then show the directions overlay.
  Future<void> _showRouteToRestaurant(DocumentSnapshot restaurantDoc) async {
    // Keep track of the existing markers so we can restore them
    _markersBeforeDirections = Set.from(_markers);

    final data = restaurantDoc.data() as Map<String, dynamic>;
    final geo = data['loc'] as GeoPoint;
    final destination = LatLng(geo.latitude, geo.longitude);

    if (_currentLocation == null) return;
    final origin = LatLng(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
    );

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['routes'] != null && jsonData['routes'].isNotEmpty) {
        final route = jsonData['routes'][0];
        final leg = route['legs'][0]; // Usually the first leg is what we need

        // Extract polyline points
        final overviewPolyline = route['overview_polyline']['points'] as String;
        final polylinePoints = PolylinePoints().decodePolyline(
          overviewPolyline,
        );
        final routeCoords =
            polylinePoints
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();

        // Parse travel distance & duration
        final distanceText = leg['distance']['text'] as String; // e.g. "9.5 km"
        final durationText = leg['duration']['text'] as String; // e.g. "14 min"
        final durationValue =
            leg['duration']['value'] as int; // e.g. 840 (seconds)
        // Compute ETA = now + durationValue
        final eta = DateTime.now().add(Duration(seconds: durationValue));
        final etaHour = eta.hour.toString().padLeft(2, '0');
        final etaMinute = eta.minute.toString().padLeft(2, '0');
        final etaText = "$etaHour:$etaMinute"; // e.g. "03:19"

        // Update the map with a single marker for the destination
        // and a polyline showing the route
        setState(() {
          // Clear existing polylines, then add the new route
          _polylines.clear();
          final polylineId = PolylineId("route");
          _polylines[polylineId] = Polyline(
            polylineId: polylineId,
            color: Colors.blue,
            width: 5,
            points: routeCoords,
          );

          // Show only the destination marker
          _markers = {
            Marker(
              markerId: MarkerId(restaurantDoc.id),
              position: destination,
              onTap: () {
                // If user taps the marker, we consider that
                // "selecting" the restaurant again
                setState(() {
                  _selectedRestaurant = restaurantDoc;
                  _searchController.text = data['name'] ?? '';
                  _exitDirectionsMode();
                });
              },
            ),
          };

          // Set the travel info
          _travelDistanceText = distanceText;
          _travelDurationText = durationText;
          _etaText = etaText;

          // Switch to directions mode
          _isDirectionsMode = true;
        });
      }
    }
  }

  /// Exit directions mode and restore original markers & polylines
  void _exitDirectionsMode() {
    setState(() {
      _isDirectionsMode = false;
      _polylines.clear();
      // Restore original markers if we have them
      if (_markersBeforeDirections != null) {
        _markers = _markersBeforeDirections!;
        _markersBeforeDirections = null;
      }
      // Clear travel info
      _travelDistanceText = null;
      _travelDurationText = null;
      _etaText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentLocation == null
              ? const Center(child: Text('Location unavailable'))
              : Stack(
                children: [
                  // Main Google Map
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
                    markers: _markers,
                    polylines: Set<Polyline>.of(_polylines.values),
                    onMapCreated: (controller) => _mapController = controller,
                    onTap:
                        (_) => setState(() {
                          _selectedRestaurant = null;
                          // If the user taps elsewhere, also exit directions mode
                          _exitDirectionsMode();
                        }),
                  ),

                  // Positioned search UI
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchBar(),
                        if (_suggestions.isNotEmpty) _buildSuggestions(),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: _buildSearchAreaButton(),
                        ),
                      ],
                    ),
                  ),

                  // If we're not in directions mode, show the bottom info popup
                  if (!_isDirectionsMode && _selectedRestaurant != null)
                    _buildBottomInfoPopup(_selectedRestaurant!),

                  // If we ARE in directions mode, show the directions overlay
                  if (_isDirectionsMode) _buildDirectionsOverlay(),
                ],
              ),
    );
  }

  /// This is the original bottom info popup for the selected restaurant
  Widget _buildBottomInfoPopup(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unnamed';
    final address = data['address'] ?? 'Address unavailable';
    final rating = (data['rating'] ?? 0).toString();
    final distance = _distances[doc.id]?.toStringAsFixed(1) ?? '?';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1B3A3B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(address, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "⭐ $rating     📍 $distance km away",
                  style: const TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    _showRouteToRestaurant(doc);
                  },
                  child: const Text(
                    'Show Directions',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Popular Dish: [dish]',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// This overlay appears at the bottom when in directions mode.
  /// It shows time taken, distance, ETA, and an "Exit" button.
  Widget _buildDirectionsOverlay() {
    // Provide default strings if they are null
    final duration = _travelDurationText ?? '';
    final distance = _travelDistanceText ?? '';
    final eta = _etaText ?? '';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black87,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // First row: big duration on the left, exit button on the right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Duration in big text, e.g. "14 min"
                Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // The exit button (red circle with X)
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _exitDirectionsMode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Second row: distance, "middle dot", ETA, plus an optional icon
            Row(
              children: [
                Expanded(
                  child: Text(
                    "$distance · $eta",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // The text field for searching
  Widget _buildSearchBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onTextChanged,
              onSubmitted: _searchRestaurantByName,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search restaurants...',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // The suggestions dropdown
  Widget _buildSuggestions() {
    final itemCount = _suggestions.length;
    final maxHeight = (itemCount * 50.0).clamp(50.0, 300.0);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return Column(
            children: [
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                horizontalTitleGap: 8,
                leading: const Icon(Icons.location_on, size: 20),
                title: Text(suggestion, style: const TextStyle(fontSize: 14)),
                onTap: () {
                  _searchController.text = suggestion;
                  _searchRestaurantByName(suggestion);
                },
              ),
              if (index < itemCount - 1) const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }

  // The "Search this area" button
  Widget _buildSearchAreaButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: () => _loadRestaurantMarkers(onlyNearby: true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: const Text('Search this area'),
      ),
    );
  }

  // Called whenever text in the search bar changes
  void _onTextChanged(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final snapshot =
        await FirebaseFirestore.instance.collection('restaurants').get();
    final List<String> matches =
        snapshot.docs
            .map(
              (doc) =>
                  (doc.data() as Map<String, dynamic>)['name']?.toString() ??
                  '',
            )
            .where((name) => name.toLowerCase().contains(input.toLowerCase()))
            .toList();
    setState(() => _suggestions = matches);
  }
}
