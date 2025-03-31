import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String restaurantId;
  const RestaurantDetailPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Restaurant'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('restaurants')
                    .doc(restaurantId)
                    .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading restaurant details.'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final doc = snapshot.data!;
              if (!doc.exists) {
                return const Center(child: Text('Restaurant not found.'));
              }

              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed';
              final rating = data['rating']?.toString() ?? '-';
              final address = data['address'] ?? '';
              final phone = data['phoneNum'] ?? '';
              final openingHours = data['openingHours'] as List<dynamic>? ?? [];
              final types = data['types'] as List<dynamic>? ?? [];

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 70,
                ), // Leave space for button
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/Mews-cafe-food-pic-2020.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(rating),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (address.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(address),
                        ),
                      const SizedBox(height: 8),
                      if (phone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Phone: $phone'),
                        ),
                      if (types.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text('Types: ${types.join(', ')}'),
                        ),
                      const Divider(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Opening Hours',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      for (final dayLine in openingHours) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          child: Text(dayLine.toString()),
                        ),
                      ],
                      const Divider(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ReviewsList(restaurantId: restaurantId),
                    ],
                  ),
                ),
              );
            },
          ),

          // Fixed Button
          Positioned(
            left: 80,
            right: 80,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/reviewform',
                  arguments: {'restaurantId': restaurantId},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC8E0CA),
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
              child: const Text(
                'Write a Review',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewsList extends StatelessWidget {
  final String restaurantId;
  const ReviewsList({Key? key, required this.restaurantId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .collection('reviews')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error loading reviews.'),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No reviews yet.'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final reviewDoc = docs[index];
            final reviewData = reviewDoc.data() as Map<String, dynamic>;

            final authorName = reviewData['authorName'] ?? 'Anonymous';
            final rating = reviewData['rating']?.toString() ?? '-';
            final text = reviewData['text'] ?? '';

            return ListTile(
              title: Text('$authorName - Rating: $rating'),
              subtitle: Text(text),
            );
          },
        );
      },
    );
  }
}
