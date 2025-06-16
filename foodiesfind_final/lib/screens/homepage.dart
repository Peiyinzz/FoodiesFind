import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/typewriter.dart';
import '../screens/near_me.dart';
import '../screens/foodies_dashboard.dart'; // ← import your dashboard
import '../widgets/top_picks_section.dart';
import '../widgets/fill_card.dart';
import '../tools/upload_synthetic_reviews.dart';

/// Try to load the menu item’s own image URL; returns empty string if none.
Future<String> fetchMenuImage(String restaurantId, String dishName) async {
  final snap =
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .where('name', isEqualTo: dishName)
          .limit(1)
          .get();

  if (snap.docs.isEmpty) return '';
  return (snap.docs.first.data()['imageUrl'] as String?) ?? '';
}

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
        username = doc['username'] as String?;
        profileImageUrl = doc['profileImageUrl'] as String?;
      });
    }
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
              // — Profile & header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/userprofile'),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                          profileImageUrl?.isNotEmpty == true
                              ? NetworkImage(profileImageUrl!)
                              : null,
                      child:
                          profileImageUrl?.isNotEmpty != true
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
                      IconButton(
                        icon: const Icon(
                          Icons.dashboard_outlined, // ← dashboard icon
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed:
                            () => Navigator.pushNamed(context, '/dashboard'),
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

              // — Search bar
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

              // — Feature cards
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

              // — Top Picks
              TopPicksSection(userId: userId),

              const SizedBox(height: 30),

              // — Popular Dishes This Week
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
                height: 130,
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('popular_dishes')
                          .orderBy('updatedAt', descending: true)
                          .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data!.docs;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final restaurantId = data['restaurantId'] as String;
                        final dishName = data['dishName'] as String;
                        final restImage = data['imageURL'] as String? ?? '';

                        return FutureBuilder<String>(
                          future: fetchMenuImage(restaurantId, dishName),
                          builder: (context, menuSnap) {
                            final imageToShow =
                                (menuSnap.hasData && menuSnap.data!.isNotEmpty)
                                    ? menuSnap.data!
                                    : restImage;
                            return FillCard(
                              imageUrl: imageToShow,
                              line1: data['restaurantName'] as String? ?? '',
                              line2: dishName,
                              line3: '${data['count'] ?? 0} recent reviews',
                              compact: true,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // — DEBUG: upload synthetic reviews
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await uploadSyntheticReviews();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Synthetic reviews uploaded!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF145858)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Upload Synthetic Reviews',
                    style: TextStyle(
                      color: Color(0xFF145858),
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
