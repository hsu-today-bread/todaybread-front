import 'order_item_response.dart';

/// 주문 생성/상세 응답 DTO
class OrderDetailResponse {
  final int orderId;
  final String storeName;
  final String status;
  final int totalAmount;
  final String orderNumber;
  final String createdAt;
  final List<OrderItemResponse> items;

  const OrderDetailResponse({
    required this.orderId,
    required this.storeName,
    required this.status,
    required this.totalAmount,
    required this.orderNumber,
    required this.createdAt,
    required this.items,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      orderId: (json['orderId'] as num).toInt(),
      storeName: json['storeName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num).toInt(),
      orderNumber: json['orderNumber'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
