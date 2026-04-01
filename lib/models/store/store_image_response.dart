class StoreImageResponse {
  final int id;
  final String imageUrl;
  final int displayOrder;

  StoreImageResponse({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory StoreImageResponse.fromJson(Map<String, dynamic> json) {
    return StoreImageResponse(
      id: (json['id'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'imageUrl': imageUrl, 'displayOrder': displayOrder};
  }
}
