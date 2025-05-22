class RecommendationItem {
  final String restaurantId;
  final String dishName;
  final int score;

  RecommendationItem({
    required this.restaurantId,
    required this.dishName,
    required this.score,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      restaurantId: json['restaurantId'],
      dishName: json['dishName'],
      score: json['score'] ?? 0,
    );
  }
}
