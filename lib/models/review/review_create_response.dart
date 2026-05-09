class ReviewCreateResponse {
  final int reviewId;
  final int orderItemId;
  final double rating;
  final String content;
  final List<String> imageUrls;
  final String createdAt;

  const ReviewCreateResponse({
    required this.reviewId,
    required this.orderItemId,
    required this.rating,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
  });

  factory ReviewCreateResponse.fromJson(Map<String, dynamic> json) {
    return ReviewCreateResponse(
      reviewId: (json['reviewId'] as num).toInt(),
      orderItemId: (json['orderItemId'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      content: json['content'] as String? ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(),
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
