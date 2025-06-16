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
  bool sortByDistance = false;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    // fallback position
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white70,
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
                    onChanged:
                        (v) => setState(() => searchQuery = v.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onPressed:
                      () => showModalBottomSheet(
                        backgroundColor: const Color(0xFF1B3A3B),
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => _buildManageBottomSheet(),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, restSnap) {
          if (restSnap.hasError) {
            return Center(
              child: Text(
                'Error: ${restSnap.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!restSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final restaurantDocs = restSnap.data!.docs;

          // load all reviews once
          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('user_reviews').get(),
            builder: (ctx, reviewSnap) {
              if (reviewSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (reviewSnap.hasError) {
                return const Center(
                  child: Text(
                    'Error loading reviews.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // map restaurantId → review count
              final counts = <String, int>{};
              for (var r in reviewSnap.data!.docs) {
                final rid = r['restaurantId'] as String? ?? '';
                if (rid.isEmpty) continue;
                counts[rid] = (counts[rid] ?? 0) + 1;
              }

              // 1) filter by search & rating
              var docs =
                  restaurantDocs.where((d) {
                    final name = (d['name'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();
              if (filterByRating) {
                docs =
                    docs
                        .where((d) => (d['rating'] ?? 0).toDouble() >= 4.0)
                        .toList();
              }

              // 2) sort
              if (sortByDistance) {
                docs.sort((a, b) {
                  double da = 1e6, db = 1e6;
                  if (currentPosition != null && a['loc'] is GeoPoint) {
                    final g = a['loc'] as GeoPoint;
                    da = calculateDistance(
                      currentPosition!.latitude,
                      currentPosition!.longitude,
                      g.latitude,
                      g.longitude,
                    );
                  }
                  if (currentPosition != null && b['loc'] is GeoPoint) {
                    final g = b['loc'] as GeoPoint;
                    db = calculateDistance(
                      currentPosition!.latitude,
                      currentPosition!.longitude,
                      g.latitude,
                      g.longitude,
                    );
                  }
                  return da.compareTo(db);
                });
              } else if (sortByRating) {
                docs.sort(
                  (a, b) => (b['rating'] ?? 0).toDouble().compareTo(
                    (a['rating'] ?? 0).toDouble(),
                  ),
                );
              } else {
                // composite relevance
                docs.sort((a, b) {
                  final da = a.data() as Map<String, dynamic>;
                  final db = b.data() as Map<String, dynamic>;
                  final aRating = (da['rating'] ?? 0).toDouble();
                  final bRating = (db['rating'] ?? 0).toDouble();
                  final aVisits = (da['visitCount'] ?? 0) as int;
                  final bVisits = (db['visitCount'] ?? 0) as int;
                  final aRevs = counts[a.id] ?? 0;
                  final bRevs = counts[b.id] ?? 0;
                  final aScore = aRating + log(aRevs + 1) + log(aVisits + 1);
                  final bScore = bRating + log(bRevs + 1) + log(bVisits + 1);
                  return bScore.compareTo(aScore);
                });
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (ctx, i) {
                  final doc = docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Unnamed';
                  final rating = data['rating']?.toString() ?? '0.0';

                  double? distanceKm;
                  if (data['loc'] is GeoPoint && currentPosition != null) {
                    final g = data['loc'] as GeoPoint;
                    distanceKm = calculateDistance(
                      currentPosition!.latitude,
                      currentPosition!.longitude,
                      g.latitude,
                      g.longitude,
                    );
                  }

                  final imageUrl = (data['imageURL'] ?? '').toString().trim();
                  final hasImage = imageUrl.isNotEmpty;

                  return GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    RestaurantDetailPage(restaurantId: doc.id),
                          ),
                        ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              hasImage
                                  ? Image.network(
                                    imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Image.asset(
                                          'assets/images/Mews-cafe-food-pic-2020.jpg',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                  )
                                  : Image.asset(
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
                                        .collection('user_reviews')
                                        .where(
                                          'restaurantId',
                                          isEqualTo: doc.id,
                                        )
                                        .get(),
                                builder: (c, snap) {
                                  final count = snap.data?.docs.length ?? 0;
                                  return Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$rating ($count reviews)',
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
            'Filters & Sort',
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
              'Sort by Name (A–Z)',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() {
                sortByDistance = false;
                sortByRating = false;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.white),
            title: const Text(
              'Sort by Rating (High→Low)',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() {
                sortByDistance = false;
                sortByRating = true;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              sortByDistance ? Icons.check_box : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            title: const Text(
              'Sort by Distance',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() => sortByDistance = !sortByDistance);
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
