class NearbyBreadResponse {
  final int id;
  final String name;
  final int originalPrice;
  final int salePrice;
  final String? imageUrl;
  final int storeId;
  final String storeName;
  final bool isSelling;
  final String? lastOrderTime;
  final double distance;

  NearbyBreadResponse({
    required this.id,
    required this.name,
    required this.originalPrice,
    required this.salePrice,
    required this.imageUrl,
    required this.storeId,
    required this.storeName,
    required this.isSelling,
    required this.lastOrderTime,
    required this.distance,
  });

  factory NearbyBreadResponse.fromJson(Map<String, dynamic> json) {
    return NearbyBreadResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      originalPrice: (json['originalPrice'] as num).toInt(),
      salePrice: (json['salePrice'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      storeId: (json['storeId'] as num).toInt(),
      storeName: json['storeName'] as String,
      isSelling: json['isSelling'] as bool? ?? false,
      lastOrderTime: json['lastOrderTime'] as String?,
      distance: (json['distance'] as num).toDouble(),
    );
  }
}
