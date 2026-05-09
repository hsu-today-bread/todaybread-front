class OrderItemResponse {
  final int? orderItemId;
  final String breadName;
  final int breadPrice;
  final int quantity;
  final String? breadImageUrl;

  const OrderItemResponse({
    this.orderItemId,
    required this.breadName,
    required this.breadPrice,
    required this.quantity,
    this.breadImageUrl,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      orderItemId: _toInt(
        json['orderItemId'] ??
            json['orderItemID'] ??
            json['order_item_id'] ??
            json['itemId'] ??
            json['id'],
      ),
      breadName: json['breadName'] as String? ?? '',
      breadPrice: _toInt(json['breadPrice']) ?? 0,
      quantity: _toInt(json['quantity']) ?? 0,
      breadImageUrl: json['breadImageUrl'] as String?,
    );
  }
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
