import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  // Controls whether we show the "Info" section (true) or "Reviews" section (false).
  bool _showGeneralInfo = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E2223),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('restaurants')
                .doc(widget.restaurantId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading restaurant details.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final doc = snapshot.data!;
          if (!doc.exists) {
            return const Center(
              child: Text(
                'Restaurant not found.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Unnamed';
          final rating = data['rating']?.toString() ?? '-';
          final address = data['address'] ?? '';
          final phone = data['phoneNum'] ?? '';
          final openingHours = data['openingHours'] as List<dynamic>? ?? [];

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========================
                    // Hero Image / Top Section
                    // ========================
                    Stack(
                      children: [
                        SizedBox(
                          height: 280,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/Mews-cafe-food-pic-2020.jpg',
                                fit: BoxFit.cover,
                              ),
                              // Dark gradient overlay
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color.fromRGBO(0, 0, 0, 0.7),
                                      Color.fromRGBO(0, 0, 0, 0.3),
                                      Color.fromRGBO(0, 0, 0, 0.0),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Back arrow
                              SafeArea(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // =========================
                    // Toggle Bar BELOW the Image
                    // =========================
                    _buildSegmentedToggle(),

                    // ======================
                    // Conditional Content
                    // ======================
                    if (_showGeneralInfo)
                      _buildGeneralInfoSection(
                        address: address,
                        phone: phone,
                        openingHours: openingHours,
                      )
                    else
                      _buildReviewsSection(),
                  ],
                ),
              ),

              // Dark overlay behind the "Write a Review" button (only in Reviews mode)
              if (!_showGeneralInfo)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(height: 100, color: const Color(0xFF0E2223)),
                ),

              // "Write a Review" button (only in Reviews view)
              if (!_showGeneralInfo)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/reviewform',
                        arguments: {'restaurantId': widget.restaurantId},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8E0CA),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: const Text(
                      'Write a Review',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Segmented toggle bar with the preferred design:
  /// - Outer container: transparent fill with a white border.
  /// - Animated thumb: white fill.
  /// - Active text: dark (0xFF0E2223); inactive text: white.
  Widget _buildSegmentedToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final segmentWidth = totalWidth / 2;
          return Container(
            width: totalWidth,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white, width: 1.5),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment:
                      _showGeneralInfo
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    width: segmentWidth,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _showGeneralInfo = true),
                        child: Container(
                          alignment: Alignment.center,
                          height: 44,
                          child: Text(
                            'Info',
                            style: TextStyle(
                              color:
                                  _showGeneralInfo
                                      ? const Color(0xFF0E2223)
                                      : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _showGeneralInfo = false),
                        child: Container(
                          alignment: Alignment.center,
                          height: 44,
                          child: Text(
                            'Reviews',
                            style: TextStyle(
                              color:
                                  !_showGeneralInfo
                                      ? const Color(0xFF0E2223)
                                      : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// General info section with additional spacing.
  /// Contains address, an underlined "View on Map" button with a map icon,
  /// phone number, opening hours, and the "View Menu" button at the bottom.
  Widget _buildGeneralInfoSection({
    required String address,
    required String phone,
    required List<dynamic> openingHours,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                '📍 $address',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          if (address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/nearMe',
                    arguments: {'restaurantId': widget.restaurantId},
                  );
                },
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text(
                  'View on Map',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    decorationThickness: 1.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.transparent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                '📞 $phone',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'Opening Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          for (final line in openingHours)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                line.toString(),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/restaurantMenu',
                  arguments: {'restaurantId': widget.restaurantId},
                );
              },
              icon: const Icon(Icons.restaurant_menu, color: Color(0xFF0E2223)),
              label: const Text(
                'View Menu',
                style: TextStyle(color: Color(0xFF0E2223), fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF0E2223)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reviews section.
  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24, thickness: 1, color: Colors.white24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ReviewsList(restaurantId: widget.restaurantId),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Reviews from Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('restaurants')
                    .doc(widget.restaurantId)
                    .collection('reviews')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
            builder: (context, googleSnapshot) {
              if (googleSnapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Error loading Google reviews.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              if (!googleSnapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }
              final googleDocs = googleSnapshot.data!.docs;
              return Column(
                children:
                    googleDocs.map((doc) {
                      final review = doc.data() as Map<String, dynamic>;
                      final author = review['authorName'] ?? 'Google User';
                      final reviewText = review['text'] ?? '';
                      final reviewRating = review['rating']?.toString() ?? '-';
                      return ListTile(
                        title: Text(
                          '$author - Rating: $reviewRating',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          reviewText,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ReviewsList extends StatefulWidget {
  final String restaurantId;
  const ReviewsList({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<ReviewsList> createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  final Map<String, bool> _expanded = {};

  Future<String> _getUsername(String userId) async {
    try {
      final snap =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      return snap.data()?['username'] ?? 'Anonymous';
    } catch (_) {
      return 'Anonymous';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('user_reviews')
              .where('restaurantId', isEqualTo: widget.restaurantId)
              .orderBy('createdAt', descending: true)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error loading user reviews.'),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }
        final docs = snapshot.data!.docs;
        return Column(
          children:
              docs.map((doc) {
                final review = doc.data() as Map<String, dynamic>;
                final docId = doc.id;
                final userId = review['userId'] ?? '';
                final rating = review['rating']?.toString() ?? '-';
                final text = review['text'] ?? '';
                final dishes = review['dishes'] as List<dynamic>? ?? [];
                return FutureBuilder<String>(
                  future: _getUsername(userId),
                  builder: (context, nameSnap) {
                    final username = nameSnap.data ?? 'Anonymous';
                    final expanded = _expanded[docId] ?? false;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '$username - Rating: $rating',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    text,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  expanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _expanded[docId] = !expanded;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (expanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    dishes.map((dishData) {
                                      final dish =
                                          dishData as Map<String, dynamic>;
                                      final dishName = dish['name'] ?? '';
                                      final tags = [
                                        ...List<String>.from(
                                          dish['taste'] ?? [],
                                        ),
                                        ...List<String>.from(
                                          dish['ingredients'] ?? [],
                                        ),
                                        ...List<String>.from(
                                          dish['dietary'] ?? [],
                                        ),
                                      ];
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text(
                                            dishName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children:
                                                tags.map((tag) {
                                                  final isTaste =
                                                      (dish['taste'] ?? [])
                                                          .contains(tag);
                                                  final isIngredient =
                                                      (dish['ingredients'] ??
                                                              [])
                                                          .contains(tag);
                                                  final isDietary =
                                                      (dish['dietary'] ?? [])
                                                          .contains(tag);
                                                  Color bg = Colors.grey;
                                                  if (isTaste) {
                                                    bg = const Color(
                                                      0xFFFBAF25,
                                                    );
                                                  } else if (isIngredient) {
                                                    bg = const Color(
                                                      0xFFC8E0CA,
                                                    );
                                                  } else if (isDietary) {
                                                    bg = const Color.fromARGB(
                                                      255,
                                                      29,
                                                      125,
                                                      125,
                                                    );
                                                  }
                                                  return Chip(
                                                    label: Text(
                                                      tag,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    backgroundColor: bg,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  );
                                                }).toList(),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
        );
      },
    );
  }
}
