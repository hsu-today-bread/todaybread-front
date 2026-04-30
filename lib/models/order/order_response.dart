import 'order_item_response.dart';

class OrderResponse {
  final int orderId;
  final String storeName;
  final String status;
  final int totalPrice;
  final String orderedAt;
  final List<OrderItemResponse> items;

  const OrderResponse({
    required this.orderId,
    required this.storeName,
    required this.status,
    required this.totalPrice,
    required this.orderedAt,
    required this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: (json['orderId'] as num).toInt(),
      storeName: json['storeName'] as String,
      status: json['status'] as String,
      totalPrice: (json['totalPrice'] as num).toInt(),
      orderedAt: json['orderedAt'] as String,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
