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
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 4, offset: Offset(0, 2), color: Colors.black12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with asset fallback
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child:
                widget.imageUrl.isNotEmpty
                    ? Image.network(
                      widget.imageUrl,
                      height: 120, // make it a bit taller if you like
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        // network load failed → fallback to asset
                        return Image.asset(
                          'assets/images/FoodiesFindSquareLogo.png',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                    : Image.asset(
                      'assets/images/FoodiesFindSquareLogo.png',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
          ),

          // Name & price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.dishName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'RM${widget.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Tags
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child:
                isLoading
                    ? const SizedBox(
                      height: 18,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : Text(
                      popularTags.join(' · '),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
          ),
        ],
      ),
    );
  }
}

/// Fetches top-3 tags by combining both editorTags and review-derived tags
Future<List<String>> getPopularTagsForDish(
  String restaurantId,
  String dishName,
) async {
  final tagCounts = <String, int>{};

  // 1) Pull in the item’s own editorTags
  final menuQuery =
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .where('name', isEqualTo: dishName)
          .limit(1)
          .get();

  if (menuQuery.docs.isNotEmpty) {
    final ed =
        menuQuery.docs.first.data()['editorTags'] as Map<String, dynamic>?;
    if (ed != null) {
      for (final category in ['taste', 'ingredients', 'dietary']) {
        final List<dynamic>? list = ed[category] as List<dynamic>?;
        if (list != null) {
          for (final tag in list) {
            tagCounts[tag as String] = (tagCounts[tag] ?? 0) + 1;
          }
        }
      }
    }
  }

  // 2) Then tally up from every review of that dish
  final reviews =
      await FirebaseFirestore.instance
          .collection('user_reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

  for (final doc in reviews.docs) {
    final data = doc.data();
    final List<dynamic> dishes = data['dishes'] ?? [];
    for (final dish in dishes) {
      if (dish['name'] == dishName) {
        for (final category in ['taste', 'ingredients', 'dietary']) {
          final List<dynamic>? list = dish[category] as List<dynamic>?;
          if (list != null) {
            for (final tag in list) {
              tagCounts[tag as String] = (tagCounts[tag] ?? 0) + 1;
            }
          }
        }
      }
    }
  }

  // 3) Sort by count desc and return top-3 keys
  final sorted =
      tagCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(3).map((e) => e.key).toList();
}
