import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_detail.dart';

class RestaurantListingPage extends StatefulWidget {
  const RestaurantListingPage({Key? key}) : super(key: key);

  @override
  State<RestaurantListingPage> createState() => _RestaurantListingPageState();
}

class _RestaurantListingPageState extends State<RestaurantListingPage> {
  String searchQuery = '';
  bool sortByRating = false;
  bool filterByRating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: const BackButton(),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.black87),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => _buildManageBottomSheet(),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('restaurants')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                // Apply filtering
                if (filterByRating) {
                  docs =
                      docs.where((doc) {
                        final rating = (doc['rating'] ?? 0).toDouble();
                        return rating >= 4.0;
                      }).toList();
                }

                // Apply search
                docs =
                    docs.where((doc) {
                      final name = (doc['name'] ?? '').toString().toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                // Apply sorting
                if (sortByRating) {
                  docs.sort(
                    (a, b) => ((b['rating'] ?? 0).toDouble()).compareTo(
                      (a['rating'] ?? 0).toDouble(),
                    ),
                  );
                } else {
                  docs.sort(
                    (a, b) => ((a['name'] ?? '') as String).compareTo(
                      (b['name'] ?? '') as String,
                    ),
                  );
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('No restaurants found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final name = data['name'] ?? 'Unnamed';
                    final rating = data['rating']?.toString() ?? '0.0';

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        leading: Image.asset(
                          'assets/images/Mews-cafe-food-pic-2020.jpg',
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(rating),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => RestaurantDetailPage(
                                    restaurantId: doc.id,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageBottomSheet() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Manage Listings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Sort by Name (A-Z)'),
            onTap: () {
              setState(() {
                sortByRating = false;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Sort by Rating (High to Low)'),
            onTap: () {
              setState(() {
                sortByRating = true;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              filterByRating ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            title: const Text('Only show rating ≥ 4.0'),
            onTap: () {
              setState(() {
                filterByRating = !filterByRating;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
