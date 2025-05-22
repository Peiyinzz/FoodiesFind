import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/typewriter.dart';
import '../tools/upload_synthetic_reviews.dart';
import 'near_me.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        username = doc['username'];
        profileImageUrl = doc['profileImageUrl'];
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecommendations(String userId) async {
    final response = await http.get(
      Uri.parse(
        'https://foodiesfind-production.up.railway.app/recommendations/$userId',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['recommendations']);
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  Future<Map<String, dynamic>> fetchRestaurantAndDishInfo(
    String restaurantId,
    String dishName,
  ) async {
    final menuSnapshot =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .collection('menu')
            .where('name', isEqualTo: dishName)
            .limit(1)
            .get();

    String imageURL = '';
    if (menuSnapshot.docs.isNotEmpty) {
      imageURL = menuSnapshot.docs.first.data()['imageURL'] ?? '';
    }

    final restaurantSnapshot =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .get();

    final data = restaurantSnapshot.data();
    final restaurantName =
        data != null && data['name'] != null ? data['name'] : restaurantId;

    return {'restaurantName': restaurantName, 'imageURL': imageURL};
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFF0E2223),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/userprofile'),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                          profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? NetworkImage(profileImageUrl!)
                              : null,
                      child:
                          profileImageUrl == null || profileImageUrl!.isEmpty
                              ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              )
                              : null,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history),
                        color: Colors.white,
                        iconSize: 26,
                        onPressed:
                            () =>
                                Navigator.pushNamed(context, '/reviewsHistory'),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Hello, ${username ?? "Username"}!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Looking for something new?',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/restaurants'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TypewriterSearchText(
                          text: 'Search restaurants, dishes...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: _ImageFeatureCard(
                      title: 'Near Me',
                      icon: Icons.location_pin,
                      backgroundImage:
                          'https://firebasestorage.googleapis.com/v0/b/foodiesfind-21552.firebasestorage.app/o/Others%2FNearMe.jpg?alt=media&token=2ec650c1-8347-42dd-889c-88b38c9d7a68',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NearbyMapScreen(),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ImageFeatureCard(
                      title: 'Featured Restaurants',
                      icon: Icons.star,
                      backgroundImage:
                          'https://images.unsplash.com/photo-1600891964599-f61ba0e24092',
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/featuredRestaurants',
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

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
                height: 120,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchRecommendations(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Text(
                        "Error loading recommendations",
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    final items = snapshot.data!;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final restaurantId = item['restaurantId'];
                        final dishName = item['dishName'];

                        return FutureBuilder<Map<String, dynamic>>(
                          future: fetchRestaurantAndDishInfo(
                            restaurantId,
                            dishName,
                          ),
                          builder: (context, infoSnapshot) {
                            if (infoSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                width: 240,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (infoSnapshot.hasError ||
                                !infoSnapshot.hasData) {
                              return const SizedBox(
                                width: 240,
                                child: Center(child: Text("❌")),
                              );
                            }

                            final info = infoSnapshot.data!;
                            return _FillCard(
                              imageUrl: info['imageURL'] ?? '',
                              line1: info['restaurantName'] ?? restaurantId,
                              line2: dishName,
                              line3: '${item['score']} pts',
                              compact: true,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // const SizedBox(height: 30),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () async {
              //       await uploadSyntheticReviews();
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(
              //           content: Text('✅ Synthetic reviews uploaded!'),
              //         ),
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.greenAccent.shade400,
              //       foregroundColor: Colors.black,
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 28,
              //         vertical: 14,
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(24),
              //       ),
              //     ),
              //     child: const Text('Upload Fake Reviews'),
              //   ),
              // ),
              const SizedBox(height: 30),
              const Text(
                'Popular Dishes This Week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 120,
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('popular_dishes')
                          .orderBy('updatedAt', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const CircularProgressIndicator();
                    final docs = snapshot.data!.docs;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return _FillCard(
                          imageUrl: data['imageURL'] ?? '',
                          line1: data['restaurantName'] ?? '',
                          line2: data['dishName'] ?? '',
                          line3: '${data['count'] ?? 0} reviews',
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageFeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String backgroundImage;
  final VoidCallback? onTap;

  const _ImageFeatureCard({
    required this.title,
    required this.icon,
    required this.backgroundImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 90,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(backgroundImage),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.70),
                BlendMode.darken,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.25),
                radius: 18,
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

class _FillCard extends StatelessWidget {
  final String imageUrl;
  final String line1;
  final String line2;
  final String line3;
  final bool compact;

  const _FillCard({
    required this.imageUrl,
    required this.line1,
    required this.line2,
    required this.line3,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = compact ? 120.0 : 160.0;
    final imageHeight = cardHeight;
    final imageWidth = 100.0;

    return Container(
      width: 260,
      height: cardHeight,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A3B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: Image.network(
              imageUrl,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: imageWidth,
                    height: imageHeight,
                    color: Colors.grey,
                    child: const Icon(Icons.image, color: Colors.white70),
                  ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line1,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: compact ? 11 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    line2,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 13 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    line3,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: compact ? 11 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
