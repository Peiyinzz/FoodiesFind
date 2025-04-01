import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String restaurantId;
  const RestaurantDetailPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/images/Mews-cafe-food-pic-2020.jpg',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
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
                            const SizedBox(height: 12),
                            if (address.isNotEmpty)
                              Text(
                                address,
                                style: const TextStyle(fontSize: 14),
                              ),
                            if (phone.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Phone: $phone',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/restaurantMenu',
                                    arguments: {'restaurantId': restaurantId},
                                  );
                                },
                                icon: const Icon(
                                  Icons.restaurant_menu,
                                  color: Color(0xFF145858),
                                ),
                                label: const Text(
                                  'View Menu',
                                  style: TextStyle(
                                    color: Color(0xFF145858),
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFFFFFF),
                                  side: const BorderSide(
                                    color: Color(0xFF145858),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24, thickness: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          'Opening Hours',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              openingHours
                                  .map(
                                    (line) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: Text(line.toString()),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      const Divider(height: 24, thickness: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
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
          // Fixed Write Review Button
          Positioned(
            left: 20,
            right: 20,
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
                backgroundColor: const Color(0xFFC8E0CA),
                padding: const EdgeInsets.symmetric(vertical: 14),
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
