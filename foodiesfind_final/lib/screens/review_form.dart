import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/success_popup.dart';
import '../widgets/tags_info.dart';

class ReviewFormPage extends StatefulWidget {
  final String restaurantId;
  const ReviewFormPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  double rating = 0;
  final TextEditingController _experienceController = TextEditingController();
  List<XFile> selectedPhotos = [];
  List<DishReview> dishes = [DishReview()];
  List<String> menuItems = [];

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

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    if (widget.restaurantId.isEmpty) return;
    final snapshot =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('menu')
            .get();
    final items =
        snapshot.docs
            .map((doc) => doc.data()['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList()
          ..sort();
    setState(() => menuItems = items);
  }

  Future<void> _pickImages() async {
    final images = await ImagePicker().pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() => selectedPhotos.addAll(images));
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit a review.')),
      );
      return;
    }
    final reviewData = {
      'userId': user.uid,
      'restaurantId': widget.restaurantId,
      'rating': rating,
      'text': _experienceController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'dishes':
          dishes
              .map(
                (dish) => {
                  'name': dish.name,
                  'taste': dish.taste,
                  'ingredients': dish.ingredients,
                  'dietary': dish.dietary,
                },
              )
              .toList(),
    };
    try {
      await FirebaseFirestore.instance
          .collection('user_reviews')
          .add(reviewData);
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit review.')));
    }
  }

  Widget _buildInfoLabel(
    String label,
    Map<String, String> descriptions,
    String title,
  ) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap:
              () => showDialog(
                context: context,
                builder:
                    (_) =>
                        TagInfoDialog(title: title, descriptions: descriptions),
              ),
          child: const Icon(Icons.info_outline, size: 18, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOptionChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFC8E0CA) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDishSection(int index) {
    final dish = dishes[index];
    final fieldWidth = MediaQuery.of(context).size.width - 40;

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dish ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (index != 0)
                IconButton(
                  padding: const EdgeInsets.only(left: 8),
                  constraints: const BoxConstraints(),
                  onPressed: () => setState(() => dishes.removeAt(index)),
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Autocomplete with scrollbar & max height =====
                Autocomplete<String>(
                  optionsBuilder: (value) {
                    final q = value.text.toLowerCase();
                    return q.isEmpty
                        ? menuItems
                        : menuItems.where(
                          (item) => item.toLowerCase().contains(q),
                        );
                  },
                  onSelected: (sel) => dish.nameController.text = sel,
                  fieldViewBuilder: (ctx, ctrl, fn, _) {
                    ctrl.text = dish.nameController.text;
                    return TextField(
                      controller: ctrl,
                      focusNode: fn,
                      decoration: InputDecoration(
                        hintText: 'Select or enter a dish',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: (v) => dish.nameController.text = v,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    final fieldWidth = MediaQuery.of(context).size.width - 60;
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: fieldWidth,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder: (ctx, i) {
                                    final option = options.elementAt(i);
                                    final isSelected =
                                        option == dish.nameController.text;
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Container(
                                        color:
                                            isSelected
                                                ? const Color(
                                                  0xFFC8E0CA,
                                                ).withOpacity(0.3)
                                                : null,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Text(option),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _buildInfoLabel('Taste', tasteTagDescriptions, 'Taste Tags'),
                const SizedBox(height: 8),
                Wrap(
                  children:
                      tasteOptions.map((t) {
                        final sel = dish.taste.contains(t);
                        return _buildOptionChip(t, sel, () {
                          setState(
                            () =>
                                sel ? dish.taste.remove(t) : dish.taste.add(t),
                          );
                        });
                      }).toList(),
                ),
                const SizedBox(height: 10),

                _buildInfoLabel(
                  'Ingredients',
                  allergyTagDescriptions,
                  'Allergy Tags',
                ),
                const SizedBox(height: 8),
                Wrap(
                  children:
                      ingredientOptions.map((i) {
                        final sel = dish.ingredients.contains(i);
                        return _buildOptionChip(i, sel, () {
                          setState(
                            () =>
                                sel
                                    ? dish.ingredients.remove(i)
                                    : dish.ingredients.add(i),
                          );
                        });
                      }).toList(),
                ),
                const SizedBox(height: 10),

                _buildInfoLabel(
                  'Dietary',
                  dietaryTagDescriptions,
                  'Dietary Tags',
                ),
                const SizedBox(height: 8),
                Wrap(
                  children:
                      dietaryOptions.map((d) {
                        final sel = dish.dietary.contains(d);
                        return _buildOptionChip(d, sel, () {
                          setState(
                            () =>
                                sel
                                    ? dish.dietary.remove(d)
                                    : dish.dietary.add(d),
                          );
                        });
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addDish() {
    if (dishes.length < 5) setState(() => dishes.add(DishReview()));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder:
          (_) =>
              const SuccessPopup(message: 'Review is submitted successfully!'),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Review'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF145858)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          FocusScope.of(context).unfocus();
          return false;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rating:'),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemBuilder:
                    (_, __) => const Icon(Icons.star, color: Colors.orange),
                onRatingUpdate: (r) => setState(() => rating = r),
              ),
              const SizedBox(height: 16),
              const Text('Describe your experience:'),
              const SizedBox(height: 6),
              TextField(
                controller: _experienceController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'How was the ambience, food and service?',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Text(
                      '+ Add photo(s)',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ),
              if (selectedPhotos.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      selectedPhotos.map((xfile) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(xfile.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                ),
              ],
              ...List.generate(dishes.length, (i) => _buildDishSection(i)),
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  onPressed: _addDish,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text(
                    'Add another dish',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DishReview {
  final TextEditingController nameController = TextEditingController();
  String get name => nameController.text;
  set name(String v) => nameController.text = v;
  List<String> taste = [];
  List<String> ingredients = [];
  List<String> dietary = [];
}
