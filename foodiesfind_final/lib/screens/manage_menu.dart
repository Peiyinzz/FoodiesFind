import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageMenuPage extends StatefulWidget {
  final String restaurantId;
  const ManageMenuPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  State<ManageMenuPage> createState() => _ManageMenuPageState();
}

class _ManageMenuPageState extends State<ManageMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E2223),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Manage Menu', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          final docs = snapshot.data!.docs;

          // Filter out documents where isPlaceholder == true
          final filteredDocs =
              docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['isPlaceholder'] != true;
              }).toList();

          // Group items by category
          final Map<String, List<DocumentSnapshot>> groupedItems = {};
          for (var doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] ?? 'Uncategorized';
            groupedItems.putIfAbsent(category, () => []).add(doc);
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children:
                      groupedItems.entries.map((entry) {
                        final category = entry.key;
                        final items = entry.value;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/manageCategory',
                                      arguments: {
                                        'restaurantId': widget.restaurantId,
                                        'categoryName': category,
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                            children:
                                items.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final name = data['name'] ?? 'Unnamed';
                                  final price =
                                      data['price']?.toString() ?? '0';
                                  return ListTile(
                                    title: Text(name),
                                    subtitle: Text('RM$price'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/manageItem',
                                          arguments: {
                                            'restaurantId': widget.restaurantId,
                                            'itemId': doc.id,
                                          },
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                          ),
                        );
                      }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC8E0CA),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => _showAddOptions(context),
                  child: const Text('Add an Item or Category'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Add a New Item'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/manageItem',
                  arguments: {'restaurantId': widget.restaurantId},
                );
              },
            ),
            ListTile(
              title: const Text('Add a New Category'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/manageCategory',
                  arguments: {'restaurantId': widget.restaurantId},
                );
              },
            ),
          ],
        );
      },
    );
  }
}
