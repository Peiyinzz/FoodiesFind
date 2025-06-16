import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// 1️⃣ Import your standalone rewards widget:
import '../widgets/redeem_rewards.dart';

class FoodiesDashboardPage extends StatefulWidget {
  const FoodiesDashboardPage({Key? key}) : super(key: key);

  @override
  State<FoodiesDashboardPage> createState() => _FoodiesDashboardPageState();
}

class _FoodiesDashboardPageState extends State<FoodiesDashboardPage> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  int? _tappedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foodies Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('user_reviews')
                  .where('userId', isEqualTo: userId)
                  .orderBy('createdAt')
                  .snapshots(),
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];

            // Build a map of yyyy-MM-dd → count of reviews
            final counts = <String, int>{};
            for (final doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final ts = data['createdAt'] as Timestamp?;
              if (ts == null) continue;
              final key = DateFormat('yyyy-MM-dd').format(ts.toDate());
              counts[key] = (counts[key] ?? 0) + 1;
            }

            // Compute the start dates of the past 6 weeks (including this week)
            final now = DateTime.now();
            final weekStarts = List<DateTime>.generate(6, (i) {
              final daysBack = (5 - i) * 7 + (now.weekday - 1);
              return DateTime(
                now.year,
                now.month,
                now.day,
              ).subtract(Duration(days: daysBack));
            });

            // Convert into FlSpots
            final spots = <FlSpot>[];
            for (var i = 0; i < weekStarts.length; i++) {
              final start = weekStarts[i];
              var sum = 0;
              for (var d = 0; d < 7; d++) {
                final key = DateFormat(
                  'yyyy-MM-dd',
                ).format(start.add(Duration(days: d)));
                sum += counts[key] ?? 0;
              }
              spots.add(FlSpot(i.toDouble(), sum.toDouble()));
            }

            // Determine Y-axis max & interval
            final maxY = spots.fold<double>(
              0,
              (prev, s) => s.y > prev ? s.y : prev,
            );
            final yInterval = maxY == 0 ? 1.0 : (maxY / 4).ceilToDouble();

            // Totals
            final totalReviews = docs.length;
            const totalVisited = 5; // replace with real data if you have it

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Top stats row ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCard(label: 'Reviews', value: '$totalReviews'),
                      _StatCard(label: 'Visited', value: '$totalVisited'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Weekly Reviews Title ──────────────────
                  const Center(
                    child: Text(
                      'Weekly Reviews',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Weekly Reviews Chart ──────────────────
                  Center(
                    child: FractionallySizedBox(
                      widthFactor:
                          0.90, // Change this (0.7~0.95) for more/less width
                      child: SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.black12),
                                bottom: BorderSide(color: Colors.black12),
                                right: BorderSide.none,
                                top: BorderSide.none,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: 1,
                                  getTitlesWidget: (x, meta) {
                                    final idx = x.toInt();
                                    if (idx < 0 || idx >= weekStarts.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final dt = weekStarts[idx];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        DateFormat('d/M').format(dt),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            minX: 0,
                            maxX: (weekStarts.length - 1).toDouble(),
                            minY: 0,
                            maxY: yInterval * 4,
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: true,
                              touchCallback: (evt, resp) {
                                if (evt is FlTapUpEvent ||
                                    evt is FlLongPressEnd) {
                                  setState(() => _tappedIndex = null);
                                } else if (resp?.lineBarSpots?.isNotEmpty ==
                                    true) {
                                  setState(
                                    () =>
                                        _tappedIndex =
                                            resp!.lineBarSpots![0].x.toInt(),
                                  );
                                }
                              },
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems:
                                    (spots) =>
                                        spots.map((spot) {
                                          return LineTooltipItem(
                                            spot.y.toInt().toString(),
                                            const TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        }).toList(),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                barWidth: 2,
                                color: Colors.teal,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Points & Level Card ──────────────────
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Level 1',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '855 Pts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Teal gradient progress bar (no yellow marker)
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0.7,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF80CBC4), // light teal
                                      Color(0xFF00897B), // dark teal
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Earn 145 more to reach Level 2',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── 7-Day Check-In Card ───────────────────
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Daily Check-In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (i) {
                              final isChecked = i == DateTime.now().weekday - 1;
                              final bonus = i == 6 ? 5 : (i + 1) ~/ 2 + 1;
                              return Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color:
                                          isChecked
                                              ? Colors.teal
                                              : Colors.grey.shade100,
                                      border: Border.all(
                                        color:
                                            isChecked
                                                ? Colors.teal.shade700
                                                : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+$bonus',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isChecked
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    i == 0 ? 'Today' : 'Day ${i + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isChecked
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // your check-in logic here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Check-in today to get 1 point',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Modular Rewards Section ──────────────
                  const RedeemRewardsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Simple stat‐card helper
class _StatCard extends StatelessWidget {
  final String label, value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
