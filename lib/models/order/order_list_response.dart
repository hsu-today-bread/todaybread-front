import 'order_response.dart';

class OrderListResponse {
  final List<OrderResponse> orders;
  final bool hasNext;

  const OrderListResponse({
    required this.orders,
    required this.hasNext,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}
