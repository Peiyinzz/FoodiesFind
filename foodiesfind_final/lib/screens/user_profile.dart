import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/tags_info.dart';

class UserProfilePage extends StatefulWidget {
  final String initialUsername;
  final String email;

  const UserProfilePage({
    Key? key,
    required this.initialUsername,
    required this.email,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  List<String> selectedAllergies = [];
  List<String> selectedDietaryPreferences = [];
  List<String> selectedTasteProfiles = [];

  final List<String> allergiesOptions = [
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

  bool showAllergyOptions = false;
  bool showDietaryOptions = false;
  bool showTasteOptions = false;
  bool _uploadingImage = false;
  File? _pickedImage;
  String? _existingProfileUrl;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _emailController = TextEditingController(text: widget.email);
    if (widget.initialUsername.isEmpty || widget.email.isEmpty) {
      _loadUserDataFromFirestore();
    } else {
      _loadExistingProfileImage();
    }
  }

  Future<void> _loadUserDataFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        _usernameController.text = doc['username'] ?? '';
        _emailController.text = doc['email'] ?? '';
        _existingProfileUrl = doc['profileImageUrl'] ?? null;
        selectedAllergies = List<String>.from(doc['allergies'] ?? []);
        selectedDietaryPreferences = List<String>.from(doc['dietary'] ?? []);
        selectedTasteProfiles = List<String>.from(doc['taste'] ?? []);
      });
    }
  }

  Future<void> _loadExistingProfileImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        _existingProfileUrl = doc['profileImageUrl'] ?? null;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take a photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      setState(() => _pickedImage = File(pickedFile.path));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() => _pickedImage = File(pickedFile.path));
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void toggleSelection(List<String> list, String value) {
    setState(() => list.contains(value) ? list.remove(value) : list.add(value));
  }

  Future<void> _saveUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
      return;
    }

    setState(() => _uploadingImage = true);
    String? imageUrl = _existingProfileUrl;

    try {
      if (_pickedImage != null) {
        final ref = FirebaseStorage.instance.ref().child(
          'profile_pictures/$uid.jpg',
        );
        await ref.putFile(_pickedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'allergies': selectedAllergies,
        'dietary': selectedDietaryPreferences,
        'taste': selectedTasteProfiles,
        'profileImageUrl': imageUrl ?? '',
      });

      setState(() => _uploadingImage = false);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Log Out'),
              ),
            ],
          ),
    );
    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_pickedImage != null) {
      imageProvider = FileImage(_pickedImage!);
    } else if (_existingProfileUrl != null && _existingProfileUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_existingProfileUrl!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: imageProvider,
                    child:
                        imageProvider == null
                            ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _sectionTitle('Username'),
            _textField(_usernameController),
            const SizedBox(height: 20),
            _sectionTitle('Email'),
            _textField(_emailController, enabled: false),
            const SizedBox(height: 20),

            // Allergies with info
            _sectionTitleWithInfo(
              'Allergies',
              onInfoTap:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) => const TagInfoDialog(
                          title: 'Allergy Tags',
                          descriptions: allergyTagDescriptions,
                        ),
                  ),
            ),
            _chipSelector(
              items: selectedAllergies,
              color: Colors.orange.shade50,
              textColor: Colors.orange.shade800,
              onDelete:
                  (item) => setState(() => selectedAllergies.remove(item)),
              toggle:
                  () =>
                      setState(() => showAllergyOptions = !showAllergyOptions),
              expanded: showAllergyOptions,
              options: allergiesOptions,
              selectedItems: selectedAllergies,
              onCheckToggle: (item) => toggleSelection(selectedAllergies, item),
            ),
            const SizedBox(height: 20),

            // Dietary with info
            _sectionTitleWithInfo(
              'Dietary Preferences',
              onInfoTap:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) => const TagInfoDialog(
                          title: 'Dietary Tags',
                          descriptions: dietaryTagDescriptions,
                        ),
                  ),
            ),
            _chipSelector(
              items: selectedDietaryPreferences,
              color: Colors.green.shade50,
              textColor: Colors.green.shade800,
              onDelete:
                  (item) =>
                      setState(() => selectedDietaryPreferences.remove(item)),
              toggle:
                  () =>
                      setState(() => showDietaryOptions = !showDietaryOptions),
              expanded: showDietaryOptions,
              options: dietaryOptions,
              selectedItems: selectedDietaryPreferences,
              onCheckToggle:
                  (item) => toggleSelection(selectedDietaryPreferences, item),
            ),
            const SizedBox(height: 20),

            // Taste with info
            _sectionTitleWithInfo(
              'Taste Profiles',
              onInfoTap:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) => const TagInfoDialog(
                          title: 'Taste Tags',
                          descriptions: tasteTagDescriptions,
                        ),
                  ),
            ),
            _chipSelector(
              items: selectedTasteProfiles,
              color: Colors.blue.shade50,
              textColor: Colors.blue.shade800,
              onDelete:
                  (item) => setState(() => selectedTasteProfiles.remove(item)),
              toggle:
                  () => setState(() => showTasteOptions = !showTasteOptions),
              expanded: showTasteOptions,
              options: tasteOptions,
              selectedItems: selectedTasteProfiles,
              onCheckToggle:
                  (item) => toggleSelection(selectedTasteProfiles, item),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _uploadingImage ? null : _saveUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8E0CA),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:
                  _uploadingImage
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Save Profile'),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _showLogoutConfirmation,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

Widget _sectionTitleWithInfo(String text, {required VoidCallback onInfoTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisSize: MainAxisSize.min, // shrink to fit
      children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 6),     // small gap
        GestureDetector(
          onTap: onInfoTap,
          child: const Icon(Icons.info_outline, size: 20, color: Colors.grey),
        ),
      ],
    ),
  );
}


  Widget _textField(TextEditingController controller, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _chipSelector({
    required List<String> items,
    required Color color,
    required Color textColor,
    required void Function(String) onDelete,
    required VoidCallback toggle,
    required bool expanded,
    required List<String> options,
    required List<String> selectedItems,
    required void Function(String) onCheckToggle,
  }) {
    const tileHeight = 40.0;
    const maxVisible = 3;
    final visibleCount =
        options.length < maxVisible ? options.length : maxVisible;
    final listHeight = visibleCount * tileHeight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
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
                      items.map((item) {
                        return Chip(
                          label: Text(item),
                          backgroundColor: color,
                          labelStyle: TextStyle(color: textColor),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => onDelete(item),
                        );
                      }).toList(),
                ),
              ),
              IconButton(
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: toggle,
              ),
            ],
          ),
          if (expanded)
            SizedBox(
              height: listHeight,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children:
                      options.map((option) {
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 8.0),
                          title: Text(
                            option,
                            style: const TextStyle(fontSize: 14),
                          ),
                          value: selectedItems.contains(option),
                          onChanged: (_) => onCheckToggle(option),
                        );
                      }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
