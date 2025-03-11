import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodiesFind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location and Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Location',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.location_on, size: 16),
                            SizedBox(width: 5),
                            Text('Bayan Baru'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.notifications_none, size: 30),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Looking For\nSomething New?\nGot It!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),

              const SizedBox(height: 25),

              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _CategoryIcon(icon: Icons.location_pin, label: 'Near Me'),
                  _CategoryIcon(icon: Icons.restaurant_menu, label: 'Dishes'),
                  _CategoryIcon(icon: Icons.storefront, label: 'Restaurants'),
                ],
              ),

              const SizedBox(height: 30),

              // Special Offers
              _SectionHeader(title: 'Special Offers'),
              _FoodCard(
                image: 'https://via.placeholder.com/80',
                title: 'Burger King',
                subtitle: '3.7 km away',
                rating: 4.5,
              ),

              const SizedBox(height: 20),

              // Restaurants
              _SectionHeader(title: 'Restaurants'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
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
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for Category Icons
class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.green.shade100,
          child: Icon(icon, color: Colors.green, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}

// Widget for section headers
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

// Food Card
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
        leading: Image.network(image, width: 60, height: 60, fit: BoxFit.cover),
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

// Horizontal Scroll Card
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
              child: Image.network(image, height: 100, width: 140, fit: BoxFit.cover)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              Text(rating.toString()),
            ],
          )
        ],
      ),
    );
  }
}
