import 'package:flutter/material.dart';
import '../widgets/typewriter.dart';
import 'near_me.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        children: [
          // Top spacer for status bar
          Container(
            height: 30,
            color: const Color(0xFF0E2223), // Match top background
          ),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // HEADER SECTION
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0E2223),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Current Location',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.location_on,
                                            color: Color(0xFFFBAF25),
                                            size: 16,
                                          ),
                                          SizedBox(width: 5),
                                          Text('Bayan Baru'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.notifications_none,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Looking For\nSomething New?\nGot It!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: 20,
                        right: 20,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap:
                              () =>
                                  Navigator.pushNamed(context, '/restaurants'),
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(16),
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
                                  TypewriterSearchText(
                                    text: 'Search restaurants, dishes...',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // CONTENT BELOW
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _CategoryIcon(
                              icon: Icons.location_pin,
                              label: 'Near Me',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NearbyMapScreen(),
                                  ),
                                );
                              },
                            ),
                            _CategoryIcon(
                              icon: Icons.restaurant_menu,
                              label: 'Dishes',
                            ),
                            _CategoryIcon(
                              icon: Icons.storefront,
                              label: 'Restaurants',
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const _SectionHeader(title: 'Special Offers'),
                        const _FoodCard(
                          image: 'https://via.placeholder.com/80',
                          title: 'Burger King',
                          subtitle: '3.7 km away',
                          rating: 4.5,
                        ),
                        const SizedBox(height: 20),
                        const _SectionHeader(title: 'Restaurants'),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: const [
                              _HorizontalFoodCard(
                                image: 'https://via.placeholder.com/120',
                                title: 'Seafood maki sushi',
                                rating: 4.5,
                              ),
                              _HorizontalFoodCard(
                                image: 'https://via.placeholder.com/120',
                                title: 'Shrimp Pasta',
                                rating: 4.3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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

class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _CategoryIcon({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green.shade100,
            child: Icon(icon, color: Colors.green, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final double rating;

  const _FoodCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(image, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 20),
            Text(rating.toString()),
          ],
        ),
      ),
    );
  }
}

class _HorizontalFoodCard extends StatelessWidget {
  final String image;
  final String title;
  final double rating;

  const _HorizontalFoodCard({
    required this.image,
    required this.title,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image,
              height: 100,
              width: 140,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              Text(rating.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
