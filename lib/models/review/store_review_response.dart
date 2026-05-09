class StoreReviewPageResponse {
  final List<StoreReviewResponse> content;
  final int totalElements;
  final int totalPages;
  final bool last;

  const StoreReviewPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory StoreReviewPageResponse.fromJson(Map<String, dynamic> json) {
    return StoreReviewPageResponse(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((value) => StoreReviewResponse.fromJson(value))
          .toList(),
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}

class StoreReviewResponse {
  final int reviewId;
  final String nickname;
  final double rating;
  final String content;
  final String breadName;
  final String? breadImageUrl;
  final List<String> imageUrls;
  final String createdAt;

  const StoreReviewResponse({
    required this.reviewId,
    required this.nickname,
    required this.rating,
    required this.content,
    required this.breadName,
    this.breadImageUrl,
    required this.imageUrls,
    required this.createdAt,
  });

  factory StoreReviewResponse.fromJson(dynamic data) {
    final json = Map<String, dynamic>.from(data as Map);
    return StoreReviewResponse(
      reviewId: (json['reviewId'] as num?)?.toInt() ?? 0,
      nickname: json['nickname'] as String? ?? '익명',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      content: json['content'] as String? ?? '',
      breadName: json['breadName'] as String? ?? '',
      breadImageUrl: json['breadImageUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(),
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
