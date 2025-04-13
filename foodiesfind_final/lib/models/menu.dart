import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadMenuItems(String restaurantId) async {
  final firestore = FirebaseFirestore.instance;

  // Load the JSON file
  final String response = await rootBundle.loadString(
    'assets/data/menu_items.json',
  );
  final List<dynamic> menuData = json.decode(response);

  final batch = firestore.batch();

  for (var item in menuData) {
    final docRef =
        firestore
            .collection('restaurants')
            .doc(restaurantId)
            .collection('menu')
            .doc(); // auto-generated ID

    batch.set(docRef, {
      'name': item['name'],
      'category': item['category'],
      'description': item['description'],
      'price': item['price'],
      'tags': item['tags'] ?? [],
      'imageUrl': item['imageUrl'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  try {
    await batch.commit();
    print('✅ Menu items uploaded successfully!');
  } catch (e) {
    print('❌ Failed to upload menu items: $e');
  }
}
