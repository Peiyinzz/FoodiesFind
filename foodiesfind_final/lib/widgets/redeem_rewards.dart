// lib/widgets/redeem_rewards.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RedeemRewardsSection extends StatelessWidget {
  const RedeemRewardsSection({Key? key}) : super(key: key);

  // Real URLs from Unsplash for demonstration
  static final List<_RewardData> _placeholders = [
    _RewardData(
      title: 'Free Coffee',
      cost: 200,
      imageUrl:
          'https://www.wikidata.org/wiki/Q8486#/media/File:A_small_cup_of_coffee.JPG',
    ),
    _RewardData(
      title: '10% Off Meal',
      cost: 300,
      imageUrl:
          'https://unsplash.com/photos/vegetable-and-meat-on-bowl-kcA-c3f_3FE',
    ),
    _RewardData(
      title: 'Movie Ticket',
      cost: 500,
      imageUrl:
          'https://images.unsplash.com/photo-1517604931442-7bd3c10305e7?auto=format&fit=crop&w=800&q=80',
    ),
    _RewardData(
      title: 'Gift Voucher',
      cost: 750,
      imageUrl:
          'https://images.unsplash.com/photo-1556740749-887f6717d7e4?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rewards',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('rewards').snapshots(),
          builder: (context, snap) {
            final rewards = <_RewardData>[];
            if (snap.hasData && snap.data!.docs.isNotEmpty) {
              for (var doc in snap.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                rewards.add(
                  _RewardData(
                    title: data['title'] as String? ?? 'Untitled',
                    cost: (data['points'] as int?) ?? 0,
                    imageUrl: data['imageUrl'] as String? ?? '',
                  ),
                );
              }
            }
            if (rewards.isEmpty) {
              rewards.addAll(_placeholders);
            }

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: rewards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final r = rewards[i];
                return _RewardCard(
                  title: r.title,
                  cost: r.cost,
                  imageUrl: r.imageUrl,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _RewardData {
  final String title;
  final int cost;
  final String imageUrl;
  const _RewardData({
    required this.title,
    required this.cost,
    required this.imageUrl,
  });
}

class _RewardCard extends StatelessWidget {
  final String title;
  final int cost;
  final String imageUrl;
  const _RewardCard({
    Key? key,
    required this.title,
    required this.cost,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // show image or fallback if URL is bad
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              '$cost points',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
