import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

typedef ShowDirectionsCallback = void Function(DocumentSnapshot restaurant);

class RestaurantPopup extends StatelessWidget {
  final DocumentSnapshot restaurantDoc;
  final double distanceKm;
  final Future<String> popularDishFuture;
  final bool isDirectionsMode;
  final String? travelDistanceText;
  final String? travelDurationText;
  final String? etaText;
  final ShowDirectionsCallback onShowDirections;
  final VoidCallback onViewMore;

  const RestaurantPopup({
    Key? key,
    required this.restaurantDoc,
    required this.distanceKm,
    required this.popularDishFuture,
    required this.isDirectionsMode,
    this.travelDistanceText,
    this.travelDurationText,
    this.etaText,
    required this.onShowDirections,
    required this.onViewMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = restaurantDoc.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Unnamed';
    final address = data['address'] as String? ?? 'Address unavailable';
    final rating = (data['rating'] as num?)?.toStringAsFixed(1) ?? '0.0';

    // Split address into two lines for readability
    final parts = address.split(', ');
    final line1 = parts.length > 2 ? parts.take(2).join(', ') : address;
    final line2 = parts.length > 2 ? parts.skip(2).join(', ') : '';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              colors: [Color(0xFF1B3A3B), Color(0xFF112323)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Restaurant name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // 2. Address lines
              Text(
                line1,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
              if (line2.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  line2,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
              const SizedBox(height: 16),

              // 3. Rating, distance, and show directions on one row
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(rating, style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km away',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => onShowDirections(restaurantDoc),
                    icon: const Icon(Icons.directions, color: Colors.white),
                    label: const Text(
                      'Show Directions',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Popular Dish as plain text with emoji
              FutureBuilder<String>(
                future: popularDishFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 20,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final dish = snap.data ?? 'N/A';
                  return Text(
                    '🍽️  Popular Dish: $dish',
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 5. Full-width View More button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewMore,
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFFBAF25),
                  ),
                  child: const Text(
                    'View More',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
