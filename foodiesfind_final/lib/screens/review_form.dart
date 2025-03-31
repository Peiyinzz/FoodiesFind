import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReviewFormPage extends StatefulWidget {
  final String restaurantId;
  const ReviewFormPage({super.key, required this.restaurantId});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  double rating = 0;
  final TextEditingController _experienceController = TextEditingController();
  List<XFile> selectedPhotos = [];
  List<DishReview> dishes = [DishReview()];

  final List<String> tasteOptions = ['Savoury', 'Light', 'Spicy', 'Sweet'];
  final List<String> ingredientOptions = [
    'Peanuts',
    'Dairy',
    'Shellfish',
    'Gluten',
  ];
  final List<String> dietaryOptions = ['Vegan', 'Vegetarian', 'Halal'];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => selectedPhotos.addAll(images));
    }
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
          border: Border.all(color: Colors.grey.shade300, width: 1),
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
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Name of the dish',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  onChanged: (value) => dish.name = value,
                ),
                const SizedBox(height: 12),
                const Text('Taste:'),
                Wrap(
                  children:
                      tasteOptions.map((t) {
                        final selected = dish.taste.contains(t);
                        return _buildOptionChip(t, selected, () {
                          setState(() {
                            selected ? dish.taste.remove(t) : dish.taste.add(t);
                          });
                        });
                      }).toList(),
                ),
                const SizedBox(height: 8),
                const Text('Did you spot these ingredients?'),
                Wrap(
                  children:
                      ingredientOptions.map((i) {
                        final selected = dish.ingredients.contains(i);
                        return _buildOptionChip(i, selected, () {
                          setState(() {
                            selected
                                ? dish.ingredients.remove(i)
                                : dish.ingredients.add(i);
                          });
                        });
                      }).toList(),
                ),
                const SizedBox(height: 8),
                const Text('Was it:'),
                Wrap(
                  children:
                      dietaryOptions.map((d) {
                        final selected = dish.dietary.contains(d);
                        return _buildOptionChip(d, selected, () {
                          setState(() {
                            selected
                                ? dish.dietary.remove(d)
                                : dish.dietary.add(d);
                          });
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
    if (dishes.length < 5) {
      setState(() => dishes.add(DishReview()));
    }
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
              onPressed: () {
                // TODO: Handle form submission
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8E0CA),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
      body: SingleChildScrollView(
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
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder:
                  (context, _) => const Icon(Icons.star, color: Colors.orange),
              onRatingUpdate: (r) => setState(() => rating = r),
            ),
            const SizedBox(height: 16),
            const Text('Describe your experience:'),
            const SizedBox(height: 6),
            TextField(
              controller: _experienceController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'How was the ambience, food and service',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
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
                  border: Border.all(color: Colors.grey.shade300, width: 1),
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
                    selectedPhotos
                        .map(
                          (xfile) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(xfile.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        .toList(),
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
    );
  }
}

class DishReview {
  String name = '';
  List<String> taste = [];
  List<String> ingredients = [];
  List<String> dietary = [];
}
