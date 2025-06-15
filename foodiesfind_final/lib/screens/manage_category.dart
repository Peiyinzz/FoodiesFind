import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCategoryPage extends StatefulWidget {
  final String restaurantId;
  final String? categoryName; // null for new, otherwise for editing
  const ManageCategoryPage({
    Key? key,
    required this.restaurantId,
    this.categoryName,
  }) : super(key: key);

  @override
  State<ManageCategoryPage> createState() => _ManageCategoryPageState();
}

class _ManageCategoryPageState extends State<ManageCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryName != null) {
      _categoryController.text = widget.categoryName!;
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final menuRef = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menu');

      final newCategory = _categoryController.text.trim();

      if (widget.categoryName != null) {
        // Edit existing category
        final batch = FirebaseFirestore.instance.batch();
        final snapshot =
            await menuRef
                .where('category', isEqualTo: widget.categoryName)
                .get();
        for (var doc in snapshot.docs) {
          batch.update(doc.reference, {'category': newCategory});
        }
        await batch.commit();
      } else {
        // Add placeholder item to represent new category
        await menuRef.add({
          'name': '',
          'price': 0,
          'category': newCategory,
          'isPlaceholder': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Category save failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save category')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteCategory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Category?'),
            content: const Text(
              'All items under this category will remain, but uncategorized.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final menuRef = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menu');
      final batch = FirebaseFirestore.instance.batch();
      final snapshot =
          await menuRef.where('category', isEqualTo: widget.categoryName).get();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'category': ''});
      }
      await batch.commit();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryName != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Category' : 'Add Category',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _deleteCategory,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator:
                    (val) => val == null || val.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8E0CA),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 10,
                  ),
                ),
                child: Text(
                  _isSaving
                      ? 'Saving...'
                      : (isEditing ? 'Update Category' : 'Save Category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}
