import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManageItemPage extends StatefulWidget {
  final String restaurantId;
  final String? itemId; // null for add, not null for edit
  const ManageItemPage({Key? key, required this.restaurantId, this.itemId})
    : super(key: key);

  @override
  State<ManageItemPage> createState() => _ManageItemPageState();
}

class _ManageItemPageState extends State<ManageItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCategory;
  File? _imageFile;
  bool _isSaving = false;
  String? _imageUrl;

  List<String> _categoryList = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.itemId != null) _loadItemData();
  }

  Future<void> _loadCategories() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('menu')
            .get();

    final categories =
        snapshot.docs
            .map((doc) => doc['category']?.toString())
            .whereType<String>()
            .toSet()
            .toList();

    setState(() {
      _categoryList = categories;
    });
  }

  Future<void> _loadItemData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('menu')
            .doc(widget.itemId)
            .get();

    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _selectedCategory = data['category'];
      _imageUrl = data['imageUrl'];
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? uploadedImageUrl = _imageUrl;

      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref().child(
          'restaurant_menu/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putFile(_imageFile!);
        uploadedImageUrl = await ref.getDownloadURL();
      }

      final itemData = {
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'category': _selectedCategory ?? '',
        'imageUrl': uploadedImageUrl ?? '',
        'tags': [],
      };

      final ref = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menu');

      if (widget.itemId != null) {
        await ref.doc(widget.itemId).update(itemData);
      } else {
        await ref.add(itemData);
      }

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving item: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save item')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Item?'),
            content: const Text('This action cannot be undone.'),
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
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menu')
          .doc(widget.itemId)
          .delete();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _deleteItem,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child:
                      _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : (_imageUrl != null && _imageUrl!.isNotEmpty)
                          ? Image.network(_imageUrl!, fit: BoxFit.cover)
                          : const Center(
                            child: Text(
                              'Add Photo',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (RM)'),
                keyboardType: TextInputType.number,
                validator:
                    (val) => val == null || val.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    _categoryList
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Select category' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28A745),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _isSaving
                      ? 'Saving...'
                      : isEditing
                      ? 'Update Item'
                      : 'Save Item',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
