import 'package:flutter/material.dart';
import '../models/menu.dart'; // Make sure this is the correct path to your function

class MenuUploadPage extends StatelessWidget {
  final String restaurantId;
  const MenuUploadPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Menu')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await uploadMenuItems(restaurantId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Menu uploaded successfully!')),
            );
            Navigator.pop(context); // Optionally go back to menu screen
          },
          child: const Text('Confirm Upload'),
        ),
      ),
    );
  }
}
