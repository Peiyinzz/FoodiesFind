import 'package:flutter/material.dart';

class FillCard extends StatelessWidget {
  final String imageUrl;
  final String line1;
  final String line2;
  final String line3;
  final bool compact;

  const FillCard({
    super.key,
    required this.imageUrl,
    required this.line1,
    required this.line2,
    required this.line3,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = compact ? 140.0 : 220.0;
    final imageHeight = cardHeight;
    final imageWidth = 120.0;

    return Container(
      width: 300,
      height: cardHeight,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A3B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 🔄 Image now has all 4 corners rounded
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: imageWidth,
                    height: imageHeight,
                    color: Colors.grey,
                    child: const Icon(Icons.image, color: Colors.white70),
                  ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Restaurant name wraps onto multiple lines
                  Text(
                    line1,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: compact ? 11 : 12,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),

                  // ✅ Dish name wraps onto multiple lines
                  Text(
                    line2,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 13 : 14,
                    ),
                    softWrap: true,
                  ),
                  const Spacer(),

                  // ✅ Tags wrap onto next line if needed
                  Text(
                    line3,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: compact ? 11 : 12,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
