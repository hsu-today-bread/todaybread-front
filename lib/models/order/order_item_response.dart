class OrderItemResponse {
  final String breadName;
  final int breadPrice;
  final int quantity;
  final String? breadImageUrl;

  const OrderItemResponse({
    required this.breadName,
    required this.breadPrice,
    required this.quantity,
    this.breadImageUrl,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      breadName: json['breadName'] as String,
      breadPrice: (json['breadPrice'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      breadImageUrl: json['breadImageUrl'] as String?,
    );
  }
}
