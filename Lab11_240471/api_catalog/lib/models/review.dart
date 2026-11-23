class Review {
  const Review({ required this.rating, required this.comment, required this.reviewerName, required this.date });

  final int rating; // 1 to 5 stars
  final String comment;
  final String reviewerName;
  final DateTime date;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        rating: (json['rating'] as num).toInt(),
        comment: json['comment'] as String,
        reviewerName: json['reviewerName'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}
