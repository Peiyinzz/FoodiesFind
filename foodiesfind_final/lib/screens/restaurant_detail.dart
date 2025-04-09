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
      body: Stack(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('restaurants')
                    .doc(restaurantId)
                    .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return const Center(
                  child: Text('Error loading restaurant details.'),
                );
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              final doc = snapshot.data!;
              if (!doc.exists)
                return const Center(child: Text('Restaurant not found.'));

              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed';
              final rating = data['rating']?.toString() ?? '-';
              final address = data['address'] ?? '';
              final phone = data['phoneNum'] ?? '';
              final openingHours = data['openingHours'] as List<dynamic>? ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 280,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/Mews-cafe-food-pic-2020.jpg',
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color.fromRGBO(0, 0, 0, 0.6),
                                      Color.fromRGBO(0, 0, 0, 0.3),
                                      Color.fromRGBO(0, 0, 0, 0.0),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 3,
                                            color: Colors.black,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (address.isNotEmpty)
                            Text(
                              'Address: $address',
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

                    /// 🕒 Opening Hours Section (RESTORED)
                    const Divider(height: 24, thickness: 1),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ReviewsList(restaurantId: restaurantId),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Reviews from Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('restaurants')
                                .doc(restaurantId)
                                .collection('reviews')
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                        builder: (context, googleSnapshot) {
                          if (googleSnapshot.hasError)
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Error loading Google reviews.'),
                            );
                          if (!googleSnapshot.hasData)
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            );

                          final googleDocs = googleSnapshot.data!.docs;
                          return Column(
                            children:
                                googleDocs.map((doc) {
                                  final review =
                                      doc.data() as Map<String, dynamic>;
                                  final name =
                                      review['authorName'] ?? 'Google User';
                                  final text = review['text'] ?? '';
                                  final rating =
                                      review['rating']?.toString() ?? '-';
                                  return ListTile(
                                    title: Text('$name - Rating: $rating'),
                                    subtitle: Text(text),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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

class ReviewsList extends StatefulWidget {
  final String restaurantId;
  const ReviewsList({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<ReviewsList> createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  final Map<String, bool> _expanded = {};

  Future<String> _getUsername(String userId) async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      return snap.data()?['username'] ?? 'Anonymous';
    } catch (_) {
      return 'Anonymous';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('user_reviews')
              .where('restaurantId', isEqualTo: widget.restaurantId)
              .orderBy('createdAt', descending: true)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error loading user reviews.'),
          );
        if (!snapshot.hasData)
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );

        final docs = snapshot.data!.docs;

        return Column(
          children:
              docs.map((doc) {
                final review = doc.data() as Map<String, dynamic>;
                final docId = doc.id;
                final userId = review['userId'] ?? '';
                final rating = review['rating']?.toString() ?? '-';
                final text = review['text'] ?? '';
                final dishes = review['dishes'] as List<dynamic>? ?? [];

                return FutureBuilder<String>(
                  future: _getUsername(userId),
                  builder: (context, nameSnap) {
                    final name = nameSnap.data ?? 'Anonymous';
                    final expanded = _expanded[docId] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('$name - Rating: $rating'),
                                  subtitle: Text(text),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  expanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onPressed:
                                    () => setState(
                                      () => _expanded[docId] = !expanded,
                                    ),
                              ),
                            ],
                          ),
                          if (expanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    dishes.map((dishData) {
                                      final dish =
                                          dishData as Map<String, dynamic>;
                                      final dishName = dish['name'] ?? '';
                                      final tags = [
                                        ...List<String>.from(
                                          dish['taste'] ?? [],
                                        ),
                                        ...List<String>.from(
                                          dish['ingredients'] ?? [],
                                        ),
                                        ...List<String>.from(
                                          dish['dietary'] ?? [],
                                        ),
                                      ];

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text(
                                            dishName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children:
                                                tags.map((tag) {
                                                  final isTaste =
                                                      (dish['taste'] ?? [])
                                                          .contains(tag);
                                                  final isIngredient =
                                                      (dish['ingredients'] ??
                                                              [])
                                                          .contains(tag);
                                                  final isDietary =
                                                      (dish['dietary'] ?? [])
                                                          .contains(tag);

                                                  Color bg = Colors.grey;
                                                  if (isTaste)
                                                    bg = const Color(
                                                      0xFFFBAF25,
                                                    ); // orange
                                                  else if (isIngredient)
                                                    bg = const Color(
                                                      0xFFC8E0CA,
                                                    ); // mint
                                                  else if (isDietary)
                                                    bg = const Color.fromARGB(
                                                      255,
                                                      29,
                                                      125,
                                                      125,
                                                    ); // teal

                                                  return Chip(
                                                    label: Text(
                                                      tag,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    backgroundColor: bg,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  );
                                                }).toList(),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
        );
      },
    );
  }
}
