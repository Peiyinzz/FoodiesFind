import 'package:flutter/material.dart';

class Restaurant {
  final String name;
  final String imageUrl;
  final String category;
  final double rating;
  final String distance;

  Restaurant({
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.distance,
  });
}

class RestaurantListingPage extends StatelessWidget {
  final List<Restaurant> restaurants = [
    Restaurant(
      name: 'Sushi Mentai',
      imageUrl: 'https://via.placeholder.com/100',
      category: 'Japanese, Sushi',
      rating: 4.3,
      distance: '5.2 km',
    ),
    Restaurant(
      name: 'Burger King',
      imageUrl: 'https://via.placeholder.com/100',
      category: 'Fast Food, Burger',
      rating: 4.5,
      distance: '3.7 km',
    ),
    Restaurant(
      name: 'Seafood Delight',
      imageUrl: 'https://via.placeholder.com/100',
      category: 'Seafood',
      rating: 4.6,
      distance: '2.8 km',
    ),
  ];

  RestaurantListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Restaurants'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Restaurant List
            Expanded(
              child: ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          restaurant.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        restaurant.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(restaurant.category),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${restaurant.rating} • ${restaurant.distance}',
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // TODO: Navigate to detail page
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
