class BreadDetailResponse {
  final int id;
  final String name;
  final int originalPrice;
  final int salePrice;
  final int remainingQuantity;
  final String description;
  final String? imageUrl;
  final int storeId;
  final String storeName;
  final bool isSelling;
  final double averageRating;
  final int reviewCount;

  const BreadDetailResponse({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.salePrice,
    required this.remainingQuantity,
    required this.description,
    required this.imageUrl,
    required this.storeId,
    required this.storeName,
    required this.isSelling,
    required this.averageRating,
    required this.reviewCount,
  });

  factory BreadDetailResponse.fromJson(Map<String, dynamic> json) {
    return BreadDetailResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      originalPrice: (json['originalPrice'] as num).toInt(),
      salePrice: (json['salePrice'] as num).toInt(),
      remainingQuantity: (json['remainingQuantity'] as num).toInt(),
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      storeId: (json['storeId'] as num).toInt(),
      storeName: json['storeName'] as String,
      isSelling: json['isSelling'] as bool? ?? false,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }
}
