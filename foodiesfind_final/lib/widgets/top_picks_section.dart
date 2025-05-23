import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'fill_card.dart';

/// Fetches recommendations from your FastAPI endpoint.
Future<List<Map<String, dynamic>>> fetchRecommendations(String userId) async {
  final response = await http.get(
    Uri.parse(
      'https://foodiesfind-production.up.railway.app/recommendations/$userId',
    ),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['recommendations']);
  }
  throw Exception('Failed to load recommendations');
}

/// 🔥 Prioritize menu item `imageUrl`, fallback to restaurant `imageURL`.
Future<Map<String, dynamic>> fetchRestaurantAndDishInfo(
  String restaurantId,
  String dishName,
) async {
  final db = FirebaseFirestore.instance;

  // 1) Try menu item imageUrl (lower-camel 'u')
  final menuSnap =
      await db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .where('name', isEqualTo: dishName)
          .limit(1)
          .get();

  String menuImage = '';
  if (menuSnap.docs.isNotEmpty) {
    final menuData = menuSnap.docs.first.data();
    menuImage = (menuData['imageUrl'] as String?) ?? '';
  }

  // 2) Fetch restaurant imageURL (upper 'URL')
  final restoSnap = await db.collection('restaurants').doc(restaurantId).get();
  final restoData = restoSnap.data() ?? {};
  final restaurantImage = (restoData['imageURL'] as String?) ?? '';

  // 3) Pick menuImage if set, else restaurantImage
  final imageUrl = menuImage.isNotEmpty ? menuImage : restaurantImage;

  // 4) Also return restaurant name
  final restaurantName = (restoData['name'] as String?) ?? restaurantId;

  return {'restaurantName': restaurantName, 'imageUrl': imageUrl};
}

/// Aggregates tags for display (unchanged).
Future<List<String>> getPopularTagsForDish(
  String restaurantId,
  String dishName,
) async {
  final snap =
      await FirebaseFirestore.instance
          .collection('user_reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

  final Map<String, int> counts = {};
  for (var doc in snap.docs) {
    final data = doc.data();
    for (var dish
        in (data['dishes'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()) {
      if (dish['name'] == dishName) {
        final tags = <String>[
          ...List<String>.from(dish['taste'] ?? []),
          ...List<String>.from(dish['ingredients'] ?? []),
          ...List<String>.from(dish['dietary'] ?? []),
        ];
        for (var tag in tags) {
          counts[tag] = (counts[tag] ?? 0) + 1;
        }
      }
    }
  }
  final sorted =
      counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(3).map((e) => e.key).toList();
}

/// Top Picks section using the corrected fetch above.
class TopPicksSection extends StatelessWidget {
  final String userId;
  const TopPicksSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Picks For You',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 130,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchRecommendations(userId),
            builder: (context, recSnap) {
              if (recSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (recSnap.hasError) {
                return const Center(
                  child: Text(
                    'Error loading recommendations',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final items = recSnap.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final restId = items[i]['restaurantId'] as String;
                  final dishName = items[i]['dishName'] as String;

                  final infoFuture = fetchRestaurantAndDishInfo(
                    restId,
                    dishName,
                  );
                  final tagsFuture = getPopularTagsForDish(restId, dishName);

                  return FutureBuilder<List<dynamic>>(
                    future: Future.wait([infoFuture, tagsFuture]),
                    builder: (context, comboSnap) {
                      if (comboSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          width: 240,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (comboSnap.hasError) {
                        return const SizedBox(
                          width: 240,
                          child: Center(child: Text('Error loading details')),
                        );
                      }

                      final info = comboSnap.data![0] as Map<String, dynamic>;
                      final tags = comboSnap.data![1] as List<String>;
                      final tagLine = tags.isNotEmpty ? tags.join(' · ') : '';

                      return FillCard(
                        imageUrl: info['imageUrl'] as String,
                        line1: info['restaurantName'] as String,
                        line2: dishName,
                        line3: tagLine,
                        compact: true,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
