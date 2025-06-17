import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'public_reviews_history.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailPage({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  bool _showGeneralInfo = true;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .update({'visitCount': FieldValue.increment(1)});
  }

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
          final address = data['address'] ?? '';
          final phone = data['phoneNum'] ?? '';
          final openingHours = data['openingHours'] as List<dynamic>? ?? [];
          final cuisine = (data['cuisineType'] ?? '').toString().trim();

          // grab imageURL, if any
          final imageUrl = (data['imageURL'] ?? '').toString().trim();
          final hasImage = imageUrl.isNotEmpty;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero section with fallback logic
                    SizedBox(
                      height: 280,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          hasImage
                              ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Image.asset(
                                      'assets/images/FoodiesFindSquareLogo.png',
                                      fit: BoxFit.cover,
                                    ),
                              )
                              : Image.asset(
                                'assets/images/FoodiesFindSquareLogo.png',
                                fit: BoxFit.cover,
                              ),
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
                          // Cuisine, if any:
                          if (cuisine.isNotEmpty)
                            Positioned(
                              bottom: 68, // just above the name
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  cuisine.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),

                          // Restaurant name
                          Positioned(
                            bottom: cuisine.isNotEmpty ? 24 : 16,
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
                          SafeArea(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/manageRestaurant',
                                      arguments: {
                                        'restaurantId': widget.restaurantId,
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSegmentedToggle(),
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

              if (!_showGeneralInfo)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(height: 100, color: const Color(0xFF0E2223)),
                ),
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
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          if (phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '📞 $phone',
                style: const TextStyle(fontSize: 14, color: Colors.white),
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
          if (openingHours.isNotEmpty) ...[
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
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
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

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24, thickness: 1, color: Color(0xFF0E2223)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ReviewSummaryWidget(restaurantId: widget.restaurantId),
        ),
        const SizedBox(height: 16),
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
        GoogleReviews(restaurantId: widget.restaurantId),
      ],
    );
  }
}

/// Summarizes user reviews from top-level 'user_reviews'.
class ReviewSummaryWidget extends StatelessWidget {
  final String restaurantId;
  const ReviewSummaryWidget({Key? key, required this.restaurantId})
    : super(key: key);

  Future<Map<String, dynamic>> _getReviewSummary() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('user_reviews')
            .where('restaurantId', isEqualTo: restaurantId)
            .get();

    double sumRatings = 0;
    int totalReviews = snapshot.docs.length;
    Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      int rating = 0;
      if (data['rating'] != null) {
        rating = (data['rating'] as num).toInt();
      }
      sumRatings += rating;
      if (starCounts.containsKey(rating)) {
        starCounts[rating] = starCounts[rating]! + 1;
      }
    }

    double avgRating = totalReviews > 0 ? sumRatings / totalReviews : 0;
    return {
      'totalReviews': totalReviews,
      'avgRating': avgRating,
      'starCounts': starCounts,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getReviewSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading review summary',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final summary = snapshot.data ?? {};
        final totalReviews = summary['totalReviews'] ?? 0;
        final avgRating = summary['avgRating'] ?? 0.0;
        final starCounts = Map<int, int>.from(summary['starCounts'] ?? {});

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalReviews reviews',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  for (int star = 5; star >= 1; star--) ...[
                    Row(
                      children: [
                        Text(
                          '$star stars',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value:
                                totalReviews > 0
                                    ? (starCounts[star] ?? 0) / totalReviews
                                    : 0,
                            backgroundColor: Colors.white24,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${starCounts[star] ?? 0}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ],
        );
      },
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
  final String _currentUserId = 'testUserId';
  final Map<String, String> _usernames = {};

  Future<String> _fetchUsername(String userId) async {
    if (_usernames.containsKey(userId)) return _usernames[userId]!;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final username =
        (doc.exists && doc.data()!.containsKey('username'))
            ? doc.get('username') as String
            : 'Anonymous';
    _usernames[userId] = username;
    return username;
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
      builder: (context, snap) {
        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error loading user reviews.'),
          );
        }
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }
        final docs = snap.data!.docs;
        return Column(
          children:
              docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final docId = doc.id;
                final userId = data['userId'] ?? '';
                final photoUrls = List<String>.from(data['photoUrls'] ?? []);

                final rating = (data['rating'] ?? 0).toDouble();
                final text = data['text'] ?? '';
                final dishes = data['dishes'] as List<dynamic>? ?? [];
                final upvotes = List<String>.from(data['upvotes'] ?? []);
                final downvotes = List<String>.from(data['downvotes'] ?? []);
                final upCount = upvotes.length;
                final downCount = downvotes.length;
                final expanded = _expanded[docId] ?? false;
                final timestamp = data['createdAt'] as Timestamp?;

                return FutureBuilder<String>(
                  future: _fetchUsername(userId),
                  builder: (context, userSnap) {
                    final username = userSnap.data ?? 'Anonymous';
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 20,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: username on top line, rating bar below, expand icon on the right
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tappable username
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => PublicReviewHistoryPage(
                                                  userId: userId,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        username,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Rating bar underneath
                                    RatingBar(rating: rating),
                                  ],
                                ),
                              ),
                              // Expand / collapse icon
                              IconButton(
                                icon: Icon(
                                  expanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onPressed: () {
                                  setState(() => _expanded[docId] = !expanded);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          Text(
                            text,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),

                          // Dish details when expanded
                          if (expanded) ...[
                            const SizedBox(height: 12),
                            for (var dishData in dishes) ...[
                              Builder(
                                builder: (_) {
                                  final dish = dishData as Map<String, dynamic>;
                                  final dishName = dish['name'] ?? '';
                                  final tags = <String>[
                                    ...List<String>.from(dish['taste'] ?? []),
                                    ...List<String>.from(
                                      dish['ingredients'] ?? [],
                                    ),
                                    ...List<String>.from(dish['dietary'] ?? []),
                                  ];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dishName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children:
                                            tags.map((tag) {
                                              Color bg = Colors.grey.shade300;
                                              if ((dish['taste'] ?? [])
                                                  .contains(tag)) {
                                                bg = const Color.fromARGB(
                                                  255,
                                                  116,
                                                  198,
                                                  241,
                                                );
                                              } else if ((dish['ingredients'] ??
                                                      [])
                                                  .contains(tag)) {
                                                bg = const Color(0xFFC8E0CA);
                                              } else if ((dish['dietary'] ?? [])
                                                  .contains(tag)) {
                                                bg = const Color.fromARGB(
                                                  255,
                                                  116,
                                                  211,
                                                  211,
                                                );
                                              }
                                              return Chip(
                                                label: Text(
                                                  tag,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor: bg,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              );
                                            }).toList(),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  );
                                },
                              ),
                            ],
                            if (photoUrls.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    photoUrls.map((url) {
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (_) => Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  child: InteractiveViewer(
                                                    child: Image.network(url),
                                                  ),
                                                ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            url,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ],
                          // Bottom row: date and votes
                          Row(
                            children: [
                              if (timestamp != null)
                                Text(
                                  timestamp
                                      .toDate()
                                      .toLocal()
                                      .toString()
                                      .split(' ')
                                      .first,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_up_alt_outlined,
                                  color:
                                      upvotes.contains(_currentUserId)
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                onPressed:
                                    () => _toggleUpvoteDownvote(
                                      doc.reference,
                                      upvotes,
                                      downvotes,
                                      isUpvote: true,
                                    ),
                              ),
                              Text(
                                '$upCount',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_down_alt_outlined,
                                  color:
                                      downvotes.contains(_currentUserId)
                                          ? Colors.red
                                          : Colors.grey,
                                ),
                                onPressed:
                                    () => _toggleUpvoteDownvote(
                                      doc.reference,
                                      upvotes,
                                      downvotes,
                                      isUpvote: false,
                                    ),
                              ),
                              Text(
                                '$downCount',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
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

  Future<void> _toggleUpvoteDownvote(
    DocumentReference reviewRef,
    List<String> upvotes,
    List<String> downvotes, {
    required bool isUpvote,
  }) async {
    if (isUpvote) {
      if (upvotes.contains(_currentUserId)) {
        upvotes.remove(_currentUserId);
      } else {
        upvotes.add(_currentUserId);
        downvotes.remove(_currentUserId);
      }
    } else {
      if (downvotes.contains(_currentUserId)) {
        downvotes.remove(_currentUserId);
      } else {
        downvotes.add(_currentUserId);
        upvotes.remove(_currentUserId);
      }
    }
    await reviewRef.update({'upvotes': upvotes, 'downvotes': downvotes});
    setState(() {});
  }
}

/// A simple star rating bar for values from 0.0 to 5.0.
class RatingBar extends StatelessWidget {
  final double rating;
  const RatingBar({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, color: Colors.amber, size: 16),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 16),
        for (int i = 0; i < emptyStars; i++)
          const Icon(Icons.star_border, color: Colors.amber, size: 16),
      ],
    );
  }
}

class GoogleReviews extends StatefulWidget {
  final String restaurantId;
  const GoogleReviews({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<GoogleReviews> createState() => _GoogleReviewsState();
}

class _GoogleReviewsState extends State<GoogleReviews> {
  final String _currentUserId = 'testUserId';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('restaurants')
              .doc(widget.restaurantId)
              .collection('reviews')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Error loading Google reviews.',
              style: TextStyle(color: Colors.white70),
            ),
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
                final author = review['authorName'] ?? 'Google User';
                final reviewText = review['text'] ?? '';
                final reviewRating = (review['rating'] ?? 0).toDouble();
                final upvotes = List<String>.from(review['upvotes'] ?? []);
                final downvotes = List<String>.from(review['downvotes'] ?? []);
                final upCount = upvotes.length;
                final downCount = downvotes.length;
                final photoUrls = List<String>.from(review['photoUrls'] ?? []);

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                author,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RatingBar(rating: reviewRating),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reviewText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up_alt_outlined,
                              color:
                                  upvotes.contains(_currentUserId)
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            onPressed: () async {
                              await _toggleUpvoteDownvote(
                                doc.reference,
                                upvotes,
                                downvotes,
                                isUpvote: true,
                              );
                            },
                          ),
                          Text(
                            '$upCount',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: Icon(
                              Icons.thumb_down_alt_outlined,
                              color:
                                  downvotes.contains(_currentUserId)
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                            onPressed: () async {
                              await _toggleUpvoteDownvote(
                                doc.reference,
                                upvotes,
                                downvotes,
                                isUpvote: false,
                              );
                            },
                          ),
                          Text(
                            '$downCount',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      // *** REVIEW DATE ***
                      if (review['createdAt'] != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              (review['createdAt'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Future<void> _toggleUpvoteDownvote(
    DocumentReference reviewRef,
    List<String> upvotes,
    List<String> downvotes, {
    required bool isUpvote,
  }) async {
    if (isUpvote) {
      if (upvotes.contains(_currentUserId)) {
        upvotes.remove(_currentUserId);
      } else {
        upvotes.add(_currentUserId);
        downvotes.remove(_currentUserId);
      }
    } else {
      if (downvotes.contains(_currentUserId)) {
        downvotes.remove(_currentUserId);
      } else {
        downvotes.add(_currentUserId);
        upvotes.remove(_currentUserId);
      }
    }
    await reviewRef.update({'upvotes': upvotes, 'downvotes': downvotes});
    setState(() {});
  }
}
