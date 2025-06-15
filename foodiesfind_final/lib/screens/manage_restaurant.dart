import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManageRestaurantPage extends StatefulWidget {
  final String restaurantId;
  const ManageRestaurantPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  State<ManageRestaurantPage> createState() => _ManageRestaurantPageState();
}

class _ManageRestaurantPageState extends State<ManageRestaurantPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _loading = true;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();

  // Cuisine dropdown
  final List<String> _cuisineOptions = [
    'Japanese',
    'Chinese',
    'Malay',
    'Indian',
    'Italian',
    'American',
    'Thai',
    'Korean',
    'Mexican',
    'Vietnamese',
  ];
  String? _selectedCuisine;
  bool _showCuisineDropdown = false; // ← NEW FLAG

  File? _pickedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .get();
    final data = doc.data() ?? {};

    _nameCtrl.text = (data['name'] as String?) ?? '';
    _addressCtrl.text = (data['address'] as String?) ?? '';
    _phoneCtrl.text = (data['phoneNum'] as String?) ?? '';
    _existingImageUrl = (data['imageURL'] as String?) ?? '';
    _hoursCtrl.text =
        (data['openingHours'] as List<dynamic>?)?.cast<String>().join('\n') ??
        '';
    _selectedCuisine = (data['cuisineType'] as String?) ?? null;

    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    String? uploadUrl = _existingImageUrl;
    if (_pickedImage != null) {
      final ref = FirebaseStorage.instance.ref().child(
        'restaurant_covers/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(_pickedImage!);
      uploadUrl = await ref.getDownloadURL();
    }

    final updated = {
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'phoneNum': _phoneCtrl.text.trim(),
      'imageURL': uploadUrl ?? '',
      'openingHours':
          _hoursCtrl.text
              .split('\n')
              .where((l) => l.trim().isNotEmpty)
              .toList(),
      'cuisineType': _selectedCuisine ?? '',
    };

    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .update(updated);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Restaurant updated')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Restaurant'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Image picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                _pickedImage != null
                                    ? Image.file(
                                      _pickedImage!,
                                      fit: BoxFit.cover,
                                    )
                                    : (_existingImageUrl?.isNotEmpty == true
                                        ? Image.network(
                                          _existingImageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                        : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              color: Colors.grey,
                                              size: 36,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Add Cover Photo',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Restaurant Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Enter name'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator:
                            (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Enter address'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Contact Number',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // — inline Cuisine dropdown —
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Cuisine Type',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: InkWell(
                          onTap:
                              () => setState(
                                () =>
                                    _showCuisineDropdown =
                                        !_showCuisineDropdown,
                              ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCuisine ?? 'Select cuisine',
                                style: TextStyle(
                                  color:
                                      _selectedCuisine == null
                                          ? Colors.grey
                                          : Colors.black,
                                ),
                              ),
                              Icon(
                                _showCuisineDropdown
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showCuisineDropdown)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SizedBox(
                              height:
                                  _cuisineOptions.length > 4
                                      ? 4 * 56.0
                                      : _cuisineOptions.length * 56.0,
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children:
                                    _cuisineOptions.map((cuisine) {
                                      return ListTile(
                                        title: Text(cuisine),
                                        onTap: () {
                                          setState(() {
                                            _selectedCuisine = cuisine;
                                            _showCuisineDropdown = false;
                                          });
                                        },
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Opening Hours
                      TextFormField(
                        controller: _hoursCtrl,
                        decoration: InputDecoration(
                          labelText: 'Opening Hours (one per line)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveRestaurant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8E0CA),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _isSaving ? 'Saving...' : 'Save Changes',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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
