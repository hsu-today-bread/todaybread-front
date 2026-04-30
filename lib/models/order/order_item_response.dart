class OrderItemResponse {
  final int breadId;
  final String breadName;
  final String? imageUrl;
  final int quantity;
  final int unitPrice;

  const OrderItemResponse({
    required this.breadId,
    required this.breadName,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      breadId: (json['breadId'] as num).toInt(),
      breadName: json['breadName'] as String,
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toInt(),
    );
  }
}
