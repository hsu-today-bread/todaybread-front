class MyReviewPageResponse {
  final List<MyReviewResponse> content;
  final int totalElements;
  final int totalPages;
  final bool last;

  const MyReviewPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory MyReviewPageResponse.fromJson(Map<String, dynamic> json) {
    return MyReviewPageResponse(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((value) => MyReviewResponse.fromJson(value))
          .toList(),
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}

class MyReviewResponse {
  final int reviewId;
  final int? orderItemId;
  final String breadName;
  final String? breadImageUrl;
  final String storeName;
  final int storeId;
  final double rating;
  final String content;
  final List<String> imageUrls;
  final String createdAt;

  const MyReviewResponse({
    required this.reviewId,
    this.orderItemId,
    required this.breadName,
    this.breadImageUrl,
    required this.storeName,
    required this.storeId,
    required this.rating,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
  });

  factory MyReviewResponse.fromJson(dynamic data) {
    final json = Map<String, dynamic>.from(data as Map);
    return MyReviewResponse(
      reviewId: (json['reviewId'] as num?)?.toInt() ?? 0,
      orderItemId: (json['orderItemId'] as num?)?.toInt(),
      breadName: json['breadName'] as String? ?? '',
      breadImageUrl: json['breadImageUrl'] as String?,
      storeName: json['storeName'] as String? ?? '',
      storeId: (json['storeId'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      content: json['content'] as String? ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(),
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
