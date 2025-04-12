import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PublicReviewHistoryPage extends StatelessWidget {
  final String userId;
  const PublicReviewHistoryPage({Key? key, required this.userId})
    : super(key: key);

  Future<Map<String, dynamic>> _fetchUsernameAndReviews() async {
    // 1) Fetch username
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final username =
        (userDoc.exists && userDoc.data()!.containsKey('username'))
            ? userDoc.get('username') as String
            : 'Anonymous';

    // 2) Fetch all their reviews
    final snap =
        await FirebaseFirestore.instance
            .collection('user_reviews')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

    final reviews = await Future.wait(
      snap.docs.map((doc) async {
        final d = doc.data();
        // also fetch restaurant name
        String restaurantName = 'Unknown';
        final rid = d['restaurantId'] as String?;
        if (rid != null) {
          final rdoc =
              await FirebaseFirestore.instance
                  .collection('restaurants')
                  .doc(rid)
                  .get();
          restaurantName = rdoc.data()?['name']?.toString() ?? 'Unknown';
        }
        return {
          'restaurantName': restaurantName,
          'text': d['text'] ?? '',
          'rating': (d['rating'] as num?)?.toDouble() ?? 0.0,
          'createdAt': d['createdAt'] as Timestamp?,
        };
      }),
    );

    return {'username': username, 'reviews': reviews};
  }

  String _formatDate(Timestamp ts) {
    return DateFormat('yyyy-MM-dd • hh:mm a').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUsernameAndReviews(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0E2223),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snap.data!;
        final username = data['username'] as String;
        final reviews = data['reviews'] as List<dynamic>;

        return Scaffold(
          backgroundColor: const Color(0xFF0E2223),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              "$username's Reviews",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body:
              reviews.isEmpty
                  ? const Center(
                    child: Text(
                      'No public reviews.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final r = reviews[i] as Map<String, dynamic>;
                      final restaurantName = r['restaurantName'] as String;
                      final text = r['text'] as String;
                      final rating = r['rating'] as double;
                      final ts = r['createdAt'] as Timestamp?;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3A3B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: name + stars
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Restaurant name
                                Expanded(
                                  child: Text(
                                    restaurantName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // Stars
                                Row(
                                  children: List.generate(5, (j) {
                                    if (j < rating.floor()) {
                                      return const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      );
                                    } else if (j < rating) {
                                      return const Icon(
                                        Icons.star_half,
                                        size: 16,
                                        color: Colors.amber,
                                      );
                                    } else {
                                      return const Icon(
                                        Icons.star_border,
                                        size: 16,
                                        color: Colors.amber,
                                      );
                                    }
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Date/time
                            if (ts != null)
                              Text(
                                _formatDate(ts),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(height: 12),
                            // Review text
                            Text(
                              text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }
}
