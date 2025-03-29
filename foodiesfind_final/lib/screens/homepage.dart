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
                  Row(
                    children: const [
                      Icon(Icons.search, color: Colors.white, size: 28),
                      SizedBox(width: 16),
                      Icon(Icons.map_outlined, color: Colors.white, size: 28),
                    ],
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
                'Wanna eat tonight?',
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

              // Categories Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _CategoryCard(
                    title: 'Sushi',
                    subtitle: '25+ Restaurants',
                    icon: Icons.set_meal,
                  ),
                  _CategoryCard(
                    title: 'Burgers',
                    subtitle: '10+ Restaurants',
                    icon: Icons.lunch_dining,
                  ),
                  _CategoryCard(
                    title: 'See All Categories',
                    subtitle: '100+ Categories',
                    icon: Icons.fastfood,
                  ),
                  _CategoryCard(
                    title: 'Near Me',
                    subtitle: 'Based on Location',
                    icon: Icons.location_pin,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NearbyMapScreen(),
                          ),
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                'RECOMMENDED',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),

              _RecommendedItem(
                imageUrl: 'https://via.placeholder.com/80',
                title: 'Get some pizza!',
                subtitle: 'Pizza  •  10% off',
                tag: 'PIZZA HUT',
              ),
              const SizedBox(height: 12),
              _RecommendedItem(
                imageUrl: 'https://via.placeholder.com/80',
                title: 'Best Deals Today!',
                subtitle: 'Limited Time Offers',
                tag: 'BURGER KING',
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
    return Row(
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
            children: [
              Text(
                tag.toUpperCase(),
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
