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
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  bool _showCategoryDropdown = false;
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

  final tasteOptions = <String>[
    'Savoury',
    'Sweet',
    'Bitter',
    'Spicy',
    'Creamy',
    'Crunchy',
    'Tangy',
    'Earthy',
  ];
  final dietaryOptions = <String>[
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
  final ingredientOptions = <String>[
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
    final snap =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('menu')
            .get();
    final cats =
        snap.docs
            .map((d) => (d.data()['category'] as String?) ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
    setState(() => _categoryList = cats);
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
      setState(() {
        _nameController.text = data['name'] ?? '';
        _priceController.text = (data['price']?.toString() ?? '');
        _selectedCategory = data['category'] as String?;
        _imageUrl = data['imageUrl'] as String?;
        final editor = data['editorTags'] as Map<String, dynamic>? ?? {};
        selectedTasteTags = List<String>.from(editor['taste'] ?? []);
        selectedDietaryTags = List<String>.from(editor['dietary'] ?? []);
        selectedIngredientTags = List<String>.from(editor['ingredients'] ?? []);
      });
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
      String? url = _imageUrl;
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref(
          'restaurant_menu/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putFile(_imageFile!);
        url = await ref.getDownloadURL();
      }

      final itemData = {
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'category': _selectedCategory ?? '',
        'imageUrl': url ?? '',
        'editorTags': {
          'taste': selectedTasteTags,
          'dietary': selectedDietaryTags,
          'ingredients': selectedIngredientTags,
        },
      };

      final coll = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menu');

      if (widget.itemId != null) {
        await coll.doc(widget.itemId).update(itemData);
      } else {
        await coll.add(itemData);
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save item')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
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
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : (_imageUrl != null && _imageUrl!.isNotEmpty
                                ? Image.network(_imageUrl!, fit: BoxFit.cover)
                                : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
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
                                  ),
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
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
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
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 12),

              // Category dropdown
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
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    // at most 4 items tall
                    height:
                        (_categoryList.length > 4 ? 4 : _categoryList.length) *
                        48.0,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _categoryList.length,
                        itemBuilder: (ctx, i) {
                          final cat = _categoryList[i];
                          return ListTile(
                            title: Text(cat),
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat;
                                _showCategoryDropdown = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Taste tags
              _buildTagSelectorBox(
                title: 'Taste Tags',
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

              // Dietary tags
              _buildTagSelectorBox(
                title: 'Dietary Tags',
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

              // Ingredient tags
              _buildTagSelectorBox(
                title: 'Ingredient Tags',
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

              // Save button with spinner
              ElevatedButton(
                onPressed: _isSaving ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8E0CA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                        : Text(isEditing ? 'Update Item' : 'Save Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagSelectorBox({
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
                        selectedTags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.grey.shade200,
                                onDeleted: () => onTagRemove(tag),
                              ),
                            )
                            .toList(),
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
                        allOptions
                            .map(
                              (tag) => CheckboxListTile(
                                dense: true,
                                title: Text(tag),
                                value: selectedTags.contains(tag),
                                onChanged: (_) => onTagToggle(tag),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
