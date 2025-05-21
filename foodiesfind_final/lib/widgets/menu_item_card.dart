import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemCard extends StatefulWidget {
  final String restaurantId;
  final String dishName;
  final double price;
  final String imageUrl;

  const MenuItemCard({
    super.key,
    required this.restaurantId,
    required this.dishName,
    required this.price,
    required this.imageUrl,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  List<String> popularTags = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTags();
  }

  Future<void> fetchTags() async {
    final tags = await getPopularTagsForDish(
      widget.restaurantId,
      widget.dishName,
    );
    setState(() {
      popularTags = tags;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270, // ✅ Slightly taller
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child:
                widget.imageUrl.isNotEmpty
                    ? Image.network(
                      widget.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                    : Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.dishName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'RM${widget.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const Spacer(), // ✅ Pushes tags to the bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child:
                isLoading
                    ? const SizedBox(
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(
                      popularTags.join(' · '), // Combine tags into one line
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis, // Prevent overflow in narrow cards
                    ),
          ),
        ],
      ),
    );
  }
}

// 🔁 Firestore tag fetcher
Future<List<String>> getPopularTagsForDish(
  String restaurantId,
  String dishName,
) async {
  final reviewSnapshot =
      await FirebaseFirestore.instance
          .collection('user_reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

  final Map<String, int> tagCounts = {};

  for (var review in reviewSnapshot.docs) {
    final data = review.data();
    final List<dynamic> dishes = data['dishes'] ?? [];

    for (var dish in dishes) {
      if (dish['name'] == dishName) {
        final List<dynamic> tags = [
          ...(dish['taste'] ?? []),
          ...(dish['ingredients'] ?? []),
          ...(dish['dietary'] ?? []),
        ];
        for (var tag in tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
    }
  }

  final sortedTags =
      tagCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  return sortedTags.take(3).map((e) => e.key).toList();
}
