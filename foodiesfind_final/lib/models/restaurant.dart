class Review {
  final String userName;
  final String userAvatar;
  final String date;
  final String content;

  Review({
    required this.userName,
    required this.userAvatar,
    required this.date,
    required this.content,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userName: map['userName'],
      userAvatar: map['userAvatar'],
      date: map['date'],
      content: map['content'],
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String address;
  final String distance;
  final double rating;
  final Map<String, String> openingHours;
  final List<Review> reviews;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.distance,
    required this.rating,
    required this.openingHours,
    required this.reviews,
  });

  // Factory method to parse JSON/map to Restaurant model
  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      address: map['address'],
      distance: map['distance'],
      rating: (map['rating'] as num).toDouble(),
      openingHours: Map<String, String>.from(map['openingHours']),
      reviews:
          (map['reviews'] as List)
              .map((reviewMap) => Review.fromMap(reviewMap))
              .toList(),
    );
  }
}
