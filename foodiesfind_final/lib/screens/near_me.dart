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
import 'restaurant_detail.dart';
import '../widgets/restaurant_popup.dart'; // <-- new import

class NearbyMapScreen extends StatefulWidget {
  final String? restaurantId; // Optional parameter

  const NearbyMapScreen({Key? key, this.restaurantId}) : super(key: key);

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

  // Polylines for drawing the route on the map (if needed)
  Map<PolylineId, Polyline> _polylines = {};

  // Track whether we're in directions mode
  bool _isDirectionsMode = false;

  // To restore the original markers after exiting directions mode
  Set<Marker>? _markersBeforeDirections;

  // Temporary storage for the restaurant popup when transitioning to directions mode.
  DocumentSnapshot? _tempRestaurant;

  // Travel info from the Directions API (used by the "Show Directions" feature)
  String? _travelDistanceText; // e.g. "9.5 km"
  String? _travelDurationText; // e.g. "14 min"
  String? _etaText; // e.g. "03:19"

  @override
  void initState() {
    super.initState();
    _placesService = GooglePlacesService(googleApiKey);
    _initializeLocation().then((_) {
      if (widget.restaurantId != null && widget.restaurantId!.isNotEmpty) {
        _fetchRestaurantDocument(widget.restaurantId!);
      }
    });
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

  Future<void> _fetchRestaurantDocument(String restaurantId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['loc'] is GeoPoint) {
          final geo = data['loc'] as GeoPoint;
          final dest = LatLng(geo.latitude, geo.longitude);
          setState(() {
            _selectedRestaurant = doc;
            _markers.add(
              Marker(markerId: MarkerId(restaurantId), position: dest),
            );
            if (_currentLocation != null) {
              _distances[doc.id] = calculateDistance(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
                geo.latitude,
                geo.longitude,
              );
            }
          });
          _moveCameraTo(dest.latitude, dest.longitude);
        }
      }
    } catch (e) {
      debugPrint("Error fetching restaurant document: $e");
    }
  }

  Future<void> _loadRestaurantMarkers({bool onlyNearby = false}) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('restaurants').get();
    final List<Marker> markers = [];
    final List<DocumentSnapshot> nearby = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['loc'] is GeoPoint) {
        final geo = data['loc'] as GeoPoint;
        final lat = geo.latitude, lng = geo.longitude;
        double? dist;
        if (_currentLocation != null) {
          dist = calculateDistance(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
            lat,
            lng,
          );
          _distances[doc.id] = dist;
        }
        if (!onlyNearby || (dist != null && dist < 5.0)) {
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              onTap: () {
                setState(() {
                  _selectedRestaurant = doc;
                  _searchController.text = (data['name'] ?? '').toString();
                  _exitDirectionsMode();
                });
              },
            ),
          );
          nearby.add(doc);
        }
      }
    }

    setState(() {
      _restaurants = nearby;
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
    String completed = input;
    if (_suggestions.isNotEmpty) {
      completed = _suggestions.firstWhere(
        (s) => s.toLowerCase().startsWith(input.toLowerCase()),
        orElse: () => input,
      );
      if (completed.toLowerCase() != input.toLowerCase()) {
        _searchController.text = completed;
      }
    }

    final snapshot =
        await FirebaseFirestore.instance.collection('restaurants').get();
    for (var doc in snapshot.docs) {
      final name = (doc['name'] ?? '').toString().toLowerCase();
      if (name.contains(completed.toLowerCase()) && doc['loc'] is GeoPoint) {
        final geo = doc['loc'] as GeoPoint;
        final lat = geo.latitude, lng = geo.longitude;
        if (_currentLocation != null) {
          _distances[doc.id] = calculateDistance(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
            lat,
            lng,
          );
        }
        setState(() {
          _selectedRestaurant = doc;
          _markers = {
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              onTap: () {
                setState(() {
                  _selectedRestaurant = doc;
                  _searchController.text = (doc['name'] ?? '').toString();
                  _exitDirectionsMode();
                });
              },
            ),
          };
          _suggestions.clear();
        });
        _moveCameraTo(lat, lng);
        break;
      }
    }
  }

  Future<void> _showRouteToRestaurant(DocumentSnapshot doc) async {
    setState(() {
      _tempRestaurant = _selectedRestaurant;
      _selectedRestaurant = null;
    });
    _markersBeforeDirections = Set.from(_markers);

    final data = doc.data() as Map<String, dynamic>;
    final geo = data['loc'] as GeoPoint;
    final dest = LatLng(geo.latitude, geo.longitude);
    if (_currentLocation == null) return;
    final orig = LatLng(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
    );

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${orig.latitude},${orig.longitude}&destination=${dest.latitude},${dest.longitude}&key=$googleApiKey';
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      final js = jsonDecode(resp.body);
      if (js['routes'] != null && js['routes'].isNotEmpty) {
        final leg = js['routes'][0]['legs'][0];
        final points = js['routes'][0]['overview_polyline']['points'] as String;
        final coords =
            PolylinePoints()
                .decodePolyline(points)
                .map((p) => LatLng(p.latitude, p.longitude))
                .toList();

        final distText = leg['distance']['text'] as String;
        final durText = leg['duration']['text'] as String;
        final eta = DateTime.now().add(
          Duration(seconds: leg['duration']['value'] as int),
        );
        final etaText =
            "${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}";

        setState(() {
          _polylines.clear();
          _polylines[PolylineId('route')] = Polyline(
            polylineId: PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: coords,
          );
          _markers = {
            Marker(
              markerId: MarkerId(doc.id),
              position: dest,
              onTap: () {
                setState(() {
                  _selectedRestaurant = doc;
                  _searchController.text = (data['name'] ?? '').toString();
                  _exitDirectionsMode();
                });
              },
            ),
          };
          _travelDistanceText = distText;
          _travelDurationText = durText;
          _etaText = etaText;
          _isDirectionsMode = true;
        });
      }
    }
  }

  void _exitDirectionsMode() {
    setState(() {
      _isDirectionsMode = false;
      _polylines.clear();
      if (_markersBeforeDirections != null) {
        _markers = _markersBeforeDirections!;
        _markersBeforeDirections = null;
      }
      _travelDistanceText = null;
      _travelDurationText = null;
      _etaText = null;
      if (_tempRestaurant != null) {
        _selectedRestaurant = _tempRestaurant;
        _tempRestaurant = null;
      }
    });
  }

  /// Computes the most “popular” dish by (mention count × average rating).
  Future<String> _fetchPopularDish(String restaurantId) async {
    final qs =
        await FirebaseFirestore.instance
            .collection('user_reviews')
            .where('restaurantId', isEqualTo: restaurantId)
            .get();

    final Map<String, int> counts = {};
    final Map<String, double> sumRatings = {};
    final Map<String, int> ratingCounts = {};

    for (var doc in qs.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      final dishes =
          (data['dishes'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

      for (var dish in dishes) {
        final name = (dish['name'] as String?) ?? '';
        if (name.isEmpty) continue;
        counts[name] = (counts[name] ?? 0) + 1;
        sumRatings[name] = (sumRatings[name] ?? 0) + rating;
        ratingCounts[name] = (ratingCounts[name] ?? 0) + 1;
      }
    }

    String popular = '';
    double bestScore = -1.0;
    counts.forEach((name, count) {
      final avg = sumRatings[name]! / ratingCounts[name]!;
      final score = count * avg;
      if (score > bestScore) {
        bestScore = score;
        popular = name;
      }
    });

    return popular;
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
                    onMapCreated: (c) => _mapController = c,
                    onTap: (_) {
                      setState(() {
                        _selectedRestaurant = null;
                        _exitDirectionsMode();
                      });
                    },
                  ),
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
                  if (!_isDirectionsMode && _selectedRestaurant != null)
                    RestaurantPopup(
                      restaurantDoc: _selectedRestaurant!,
                      distanceKm: _distances[_selectedRestaurant!.id] ?? 0,
                      popularDishFuture: _fetchPopularDish(
                        _selectedRestaurant!.id,
                      ),
                      isDirectionsMode: _isDirectionsMode,
                      travelDistanceText: _travelDistanceText,
                      travelDurationText: _travelDurationText,
                      etaText: _etaText,
                      onShowDirections: _showRouteToRestaurant,
                      onViewMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => RestaurantDetailPage(
                                  restaurantId: _selectedRestaurant!.id,
                                ),
                          ),
                        );
                      },
                    ),
                  if (_isDirectionsMode) _buildDirectionsOverlay(),
                ],
              ),
    );
  }

  Widget _buildDirectionsOverlay() {
    final d = _travelDurationText ?? '';
    final dist = _travelDistanceText ?? '';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  d,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    "$dist · $eta",
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

  Widget _buildSuggestions() {
    final count = _suggestions.length;
    final maxH = (count * 50.0).clamp(50.0, 300.0);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      constraints: BoxConstraints(maxHeight: maxH),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: count,
        itemBuilder: (ctx, i) {
          final s = _suggestions[i];
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
                title: Text(s, style: const TextStyle(fontSize: 14)),
                onTap: () {
                  _searchController.text = s;
                  _searchRestaurantByName(s);
                },
              ),
              if (i < count - 1) const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }

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

  void _onTextChanged(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final snapshot =
        await FirebaseFirestore.instance.collection('restaurants').get();
    final matches =
        snapshot.docs
            .map(
              (d) =>
                  (d.data() as Map<String, dynamic>)['name']?.toString() ?? '',
            )
            .where((n) => n.toLowerCase().contains(input.toLowerCase()))
            .toList();
    setState(() => _suggestions = matches);
  }
}
