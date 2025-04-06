import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/typewriter.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E2223),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Row
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
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Greeting
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

              // Search Bar
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
                        child: GestureDetector(
                          onTap:
                              () =>
                                  Navigator.pushNamed(context, '/restaurants'),
                          child: TypewriterSearchText(
                            text: 'Search restaurants, dishes...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Top Feature Banners (Image-backed)
              Row(
                children: [
                  Expanded(
                    child: _ImageFeatureCard(
                      title: 'Near Me',
                      subtitle: '',
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
                      subtitle: '',
                      icon: Icons.star,
                      backgroundImage:
                          'https://images.unsplash.com/photo-1600891964599-f61ba0e24092',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                'Top Picks For You',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _RecommendedItem(
                      imageUrl:
                          'https://firebasestorage.googleapis.com/v0/b/foodiesfind-21552.firebasestorage.app/o/Owned%20food%20images%2FInheritTasteCrepeCake.jpg?alt=media&token=1337b4fc-e3bd-4641-ae6b-57a15782d110',
                      title: 'Kenny Hills Bakery',
                      subtitle: 'Mille Crepe',
                      tag: 'Halal',
                    ),
                    const SizedBox(width: 12),
                    _RecommendedItem(
                      imageUrl:
                          'https://firebasestorage.googleapis.com/v0/b/foodiesfind-21552.firebasestorage.app/o/Owned%20food%20images%2FSalmonMentaiAburiMaki.webp?alt=media&token=286886bd-2a9a-4997-a77c-52d112f31d7b',
                      title: 'Sushi Mentai',
                      subtitle: 'Vegan Delights',
                      tag: 'Light',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                'Popular Dishes This Week',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _RecommendedItem(
                      imageUrl:
                          'https://firebasestorage.googleapis.com/v0/b/foodiesfind-21552.firebasestorage.app/o/Owned%20food%20images%2FPastaCarbonara.jpg?alt=media&token=dc5a7a68-7d83-4068-81a0-77ce91f65b8e',
                      title: 'Carbonara',
                      subtitle: '43 reviews',
                      tag: 'Pasta',
                    ),
                    const SizedBox(width: 12),
                    _RecommendedItem(
                      imageUrl:
                          'https://firebasestorage.googleapis.com/v0/b/foodiesfind-21552.firebasestorage.app/o/Owned%20food%20images%2FTiramisuCake.jpg?alt=media&token=60eba851-54c4-4e1c-aec3-36a7c2992521',
                      title: 'Tiramisu Cake',
                      subtitle: '24 reviews',
                      tag: 'Dessert',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A3B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: Colors.teal.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}

class _RecommendedItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String tag;

  const _RecommendedItem({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A3B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tag.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFC8E0CA),
                    fontSize: 12,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String backgroundImage;
  final VoidCallback? onTap;

  const _ImageFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 90, // ✅ Shorter height
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
