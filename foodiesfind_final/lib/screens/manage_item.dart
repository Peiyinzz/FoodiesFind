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
  bool _showCategoryDropdown = false; // NEW
  File? _imageFile;
  bool _isSaving = false;
  String? _imageUrl;

  List<String> _categoryList = [];

  List<String> selectedTasteTags = [];
  List<String> selectedDietaryTags = [];
  List<String> selectedIngredientTags = [];

  bool showTasteTags = false;
  bool showDietaryTags = false;
  bool showIngredientTags = false;

  final List<String> tasteOptions = [
    'Savoury',
    'Sweet',
    'Bitter',
    'Spicy',
    'Creamy',
    'Crunchy',
    'Tangy',
    'Earthy',
  ];
  final List<String> dietaryOptions = [
    'Vegan',
    'Vegetarian',
    'Halal',
    'Pescatarian',
    'Dairy-free',
    'Gluten-free',
    'Nut-free',
    'Low-sugar',
    'Low-carb',
    'Low-fat',
  ];
  final List<String> ingredientOptions = [
    'Peanuts',
    'Tree nuts',
    'Soy',
    'Dairy',
    'Shellfish',
    'Fish',
    'Eggs',
    'Gluten',
  ];

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
    setState(() => _categoryList = categories);
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

      final editorTags = data['editorTags'] as Map<String, dynamic>? ?? {};
      selectedTasteTags = List<String>.from(editorTags['taste'] ?? []);
      selectedDietaryTags = List<String>.from(editorTags['dietary'] ?? []);
      selectedIngredientTags = List<String>.from(
        editorTags['ingredients'] ?? [],
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
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
        'editorTags': {
          'taste': selectedTasteTags,
          'dietary': selectedDietaryTags,
          'ingredients': selectedIngredientTags,
        },
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
    final confirm = await showDialog<bool>(
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : (_imageUrl?.isNotEmpty == true
                                ? Image.network(_imageUrl!, fit: BoxFit.cover)
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Item Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (RM)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 12),

              // CATEGORY (inline dropdown)
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: InkWell(
                  onTap:
                      () => setState(
                        () => _showCategoryDropdown = !_showCategoryDropdown,
                      ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory ?? 'Select category',
                        style: TextStyle(
                          color:
                              _selectedCategory == null
                                  ? Colors.grey
                                  : Colors.black,
                        ),
                      ),
                      Icon(
                        _showCategoryDropdown
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      ),
                    ],
                  ),
                ),
              ),

              if (_showCategoryDropdown)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SizedBox(
                      // show at most 4 items (each ~56px high)
                      height:
                          (_categoryList.length > 4
                              ? 4 * 56.0
                              : _categoryList.length * 56.0),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children:
                            _categoryList.map((cat) {
                              return ListTile(
                                title: Text(cat),
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = cat;
                                    _showCategoryDropdown = false;
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Tag selectors (unchanged)
              buildTagSelectorBox(
                title: "Taste Tags",
                selectedTags: selectedTasteTags,
                allOptions: tasteOptions,
                expanded: showTasteTags,
                onToggle: () => setState(() => showTasteTags = !showTasteTags),
                onTagToggle:
                    (tag) => setState(() {
                      selectedTasteTags.contains(tag)
                          ? selectedTasteTags.remove(tag)
                          : selectedTasteTags.add(tag);
                    }),
                onTagRemove:
                    (tag) => setState(() => selectedTasteTags.remove(tag)),
              ),
              buildTagSelectorBox(
                title: "Dietary Tags",
                selectedTags: selectedDietaryTags,
                allOptions: dietaryOptions,
                expanded: showDietaryTags,
                onToggle:
                    () => setState(() => showDietaryTags = !showDietaryTags),
                onTagToggle:
                    (tag) => setState(() {
                      selectedDietaryTags.contains(tag)
                          ? selectedDietaryTags.remove(tag)
                          : selectedDietaryTags.add(tag);
                    }),
                onTagRemove:
                    (tag) => setState(() => selectedDietaryTags.remove(tag)),
              ),
              buildTagSelectorBox(
                title: "Ingredient Tags",
                selectedTags: selectedIngredientTags,
                allOptions: ingredientOptions,
                expanded: showIngredientTags,
                onToggle:
                    () => setState(
                      () => showIngredientTags = !showIngredientTags,
                    ),
                onTagToggle:
                    (tag) => setState(() {
                      selectedIngredientTags.contains(tag)
                          ? selectedIngredientTags.remove(tag)
                          : selectedIngredientTags.add(tag);
                    }),
                onTagRemove:
                    (tag) => setState(() => selectedIngredientTags.remove(tag)),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8E0CA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isSaving
                      ? 'Saving...'
                      : (isEditing ? 'Update Item' : 'Save Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTagSelectorBox({
    required String title,
    required List<String> selectedTags,
    required List<String> allOptions,
    required bool expanded,
    required VoidCallback onToggle,
    required void Function(String) onTagToggle,
    required void Function(String) onTagRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        selectedTags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey.shade200,
                            onDeleted: () => onTagRemove(tag),
                          );
                        }).toList(),
                  ),
                ),
                IconButton(
                  icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: onToggle,
                ),
              ],
            ),
            if (expanded)
              SizedBox(
                height: 140,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children:
                        allOptions.map((tag) {
                          return CheckboxListTile(
                            dense: true,
                            title: Text(tag),
                            value: selectedTags.contains(tag),
                            onChanged: (_) => onTagToggle(tag),
                          );
                        }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
