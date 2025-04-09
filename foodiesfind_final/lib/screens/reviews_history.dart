import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewHistoryPage extends StatelessWidget {
  const ReviewHistoryPage({super.key});

  Future<List<Map<String, dynamic>>> fetchUserReviews() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('user_reviews')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .get();

    final reviews = await Future.wait(
      snapshot.docs.map((doc) async {
        final data = doc.data();
        final restaurantId = data['restaurantId'];
        String restaurantName = 'Unknown';

        if (restaurantId != null) {
          final restaurantDoc =
              await FirebaseFirestore.instance
                  .collection('restaurants')
                  .doc(restaurantId)
                  .get();
          restaurantName = restaurantDoc.data()?['name'] ?? 'Unknown';
        }

        return {
          'restaurantName': restaurantName,
          'text': data['text'] ?? '',
          'createdAt': data['createdAt'],
        };
      }),
    );

    return reviews;
  }

  String formatDateTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd • hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E2223),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'My Review History',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // ← back icon color
        elevation: 0,
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return const Center(
              child: Text(
                'No reviews yet.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final restaurantName = review['restaurantName'];
              final reviewText = review['text'];
              final timestamp = review['createdAt'] as Timestamp?;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3A3B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (timestamp != null)
                      Text(
                        formatDateTime(timestamp),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      reviewText,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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
}
