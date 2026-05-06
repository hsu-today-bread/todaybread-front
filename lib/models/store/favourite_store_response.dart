class FavouriteStoreResponse {
  final int storeId;
  final String name;
  final String address;
  final String? imageUrl;
  final bool isSelling;

  const FavouriteStoreResponse({
    required this.storeId,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.isSelling,
  });

  factory FavouriteStoreResponse.fromJson(Map<String, dynamic> json) {
    return FavouriteStoreResponse(
      storeId: (json['storeId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: (json['imageUrl'] ?? json['primaryImageUrl']) as String?,
      isSelling: json['isSelling'] as bool? ?? false,
    );
  }
}
