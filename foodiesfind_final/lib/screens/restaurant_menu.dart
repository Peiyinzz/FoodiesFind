import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu.dart';
import '../widgets/menu_item_card.dart'; // Make sure this file exists

class RestaurantMenuPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantMenuPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  String searchQuery = '';
  List<String> categories = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('menu')
            .get();

    final fetchedCategories =
        snapshot.docs
            .map((doc) => doc['category']?.toString())
            .whereType<String>()
            .toSet()
            .toList();

    fetchedCategories.sort();

    setState(() {
      categories = ['All', ...fetchedCategories];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E2223),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Menu', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.upload_file),
          //   onPressed: () async {
          //     await uploadMenuItems(widget.restaurantId);
          //     if (context.mounted) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         const SnackBar(
          //           content: Text('✅ Menu uploaded successfully!'),
          //         ),
          //       );
          //     }
          //   },
          //   tooltip: 'Upload Menu',
          // ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/manageMenu',
                arguments: {'restaurantId': widget.restaurantId},
              );
            },
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color:
                            isSelected
                                ? const Color(0xFFC8E0CA)
                                : const Color(0xFF0E2223),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected:
                        (_) => setState(() => selectedCategory = category),
                    selectedColor: const Color(0xFF0E2223),
                    backgroundColor: const Color(0xFFB0CFC0),
                    checkmarkColor: const Color(0xFFC8E0CA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side:
                          isSelected
                              ? const BorderSide(
                                color: Color(0xFFC8E0CA),
                                width: 1.5,
                              )
                              : BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('restaurants')
                      .doc(widget.restaurantId)
                      .collection('menu')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items =
                    snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .where(
                          (data) =>
                              data['isPlaceholder'] != true &&
                              (data['name']?.toString().toLowerCase().contains(
                                    searchQuery,
                                  ) ??
                                  false),
                        )
                        .toList();

                if (selectedCategory != 'All') {
                  items.removeWhere(
                    (item) => item['category'] != selectedCategory,
                  );
                }

                items.sort(
                  (a, b) =>
                      (a['category'] ?? '').compareTo(b['category'] ?? ''),
                );

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final data = items[index];
                    final name = data['name'] ?? 'Unnamed';
                    final price = data['price'] ?? 0;
                    final imageUrl = data['imageUrl'] ?? '';

                    return MenuItemCard(
                      restaurantId: widget.restaurantId,
                      dishName: name,
                      price: (price is int ? price.toDouble() : price),
                      imageUrl: imageUrl,
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
}
