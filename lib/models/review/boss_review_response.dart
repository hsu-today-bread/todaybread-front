class BossReviewPageResponse {
  final List<BossReviewResponse> content;
  final int totalElements;
  final int totalPages;
  final bool last;

  const BossReviewPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory BossReviewPageResponse.fromJson(Map<String, dynamic> json) {
    return BossReviewPageResponse(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((value) => BossReviewResponse.fromJson(value))
          .toList(),
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}

class BossReviewResponse {
  final int reviewId;
  final String nickname;
  final double rating;
  final String content;
  final String breadName;
  final String? breadImageUrl;
  final List<String> imageUrls;
  final String createdAt;
  final int purchaseCount;

  const BossReviewResponse({
    required this.reviewId,
    required this.nickname,
    required this.rating,
    required this.content,
    required this.breadName,
    this.breadImageUrl,
    required this.imageUrls,
    required this.createdAt,
    required this.purchaseCount,
  });

  factory BossReviewResponse.fromJson(dynamic data) {
    final json = Map<String, dynamic>.from(data as Map);
    return BossReviewResponse(
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
      purchaseCount: (json['purchaseCount'] as num?)?.toInt() ?? 0,
    );
  }
}
