import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'restaurant_detail.dart';

class RestaurantListingPage extends StatefulWidget {
  const RestaurantListingPage({Key? key}) : super(key: key);

  @override
  State<RestaurantListingPage> createState() => _RestaurantListingPageState();
}

class _RestaurantListingPageState extends State<RestaurantListingPage> {
  String searchQuery = '';
  bool sortByRating = false;
  bool filterByRating = false;

  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    currentPosition = Position(
      latitude: 5.3564,
      longitude: 100.3015,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 1.0,
      headingAccuracy: 1.0,
      altitudeAccuracy: 1.0,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E2223),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          leading: const BackButton(color: Colors.white),
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: const Color(0xFF1B3A3B),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: const Color(0xFF1B3A3B),
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => _buildManageBottomSheet(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

          if (filterByRating) {
            docs =
                docs
                    .where((doc) => (doc['rating'] ?? 0).toDouble() >= 4.0)
                    .toList();
          }

          docs =
              docs.where((doc) {
                final name = (doc['name'] ?? '').toString().toLowerCase();
                return name.contains(searchQuery);
              }).toList();

          if (sortByRating) {
            docs.sort(
              (a, b) => ((b['rating'] ?? 0).toDouble()).compareTo(
                (a['rating'] ?? 0).toDouble(),
              ),
            );
          } else {
            docs.sort(
              (a, b) => ((a['name'] ?? '') as String).compareTo(
                (b['name'] ?? '') as String,
              ),
            );
          }

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No restaurants found.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Unnamed';
              final rating = data['rating']?.toString() ?? '0.0';

              double? distanceKm;
              if (data['loc'] != null && data['loc'] is GeoPoint) {
                final geo = data['loc'] as GeoPoint;
                distanceKm = calculateDistance(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                  geo.latitude,
                  geo.longitude,
                );
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => RestaurantDetailPage(restaurantId: doc.id),
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/Mews-cafe-food-pic-2020.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                distanceKm != null
                                    ? '${distanceKm.toStringAsFixed(1)} km away'
                                    : 'Distance unknown',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          FutureBuilder<QuerySnapshot>(
                            future:
                                FirebaseFirestore.instance
                                    .collection('restaurants')
                                    .doc(doc.id)
                                    .collection('reviews')
                                    .get(),
                            builder: (context, reviewSnapshot) {
                              final reviewCount =
                                  reviewSnapshot.data?.docs.length ?? 0;
                              return Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$rating ($reviewCount reviews)',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildManageBottomSheet() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha, color: Colors.white),
            title: const Text(
              'Sort by Name (A-Z)',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() => sortByRating = false);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.white),
            title: const Text(
              'Sort by Rating (High to Low)',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() => sortByRating = true);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              filterByRating ? Icons.check_box : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            title: const Text(
              'Only show rating ≥ 4.0',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() => filterByRating = !filterByRating);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
