class NearbyStoreResponse {
  final int storeId;
  final String name;
  final String storeAddressLine1;
  final String storeAddressLine2;
  final double latitude;
  final double longitude;
  final String? primaryImageUrl;
  final bool isSelling;
  final double distance;
  final String? lastOrderTime;
  final double averageRating;
  final int reviewCount;

  const NearbyStoreResponse({
    required this.storeId,
    required this.name,
    required this.storeAddressLine1,
    required this.storeAddressLine2,
    required this.latitude,
    required this.longitude,
    this.primaryImageUrl,
    required this.isSelling,
    required this.distance,
    this.lastOrderTime,
    required this.averageRating,
    required this.reviewCount,
  });

  factory NearbyStoreResponse.fromJson(Map<String, dynamic> json) {
    return NearbyStoreResponse(
      storeId: (json['storeId'] as num).toInt(),
      name: json['name'] as String,
      storeAddressLine1: json['storeAddressLine1'] as String? ?? '',
      storeAddressLine2: json['storeAddressLine2'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      primaryImageUrl: (json['primaryImageUrl'] ?? json['imageUrl']) as String?,
      isSelling: json['isSelling'] as bool? ?? false,
      distance: (json['distance'] as num).toDouble(),
      lastOrderTime: json['lastOrderTime'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }
}
