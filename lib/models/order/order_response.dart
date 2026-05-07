/// 주문 목록 항목 DTO (GET /api/orders 의 content[] 내 각 항목)
class OrderResponse {
  final int orderId;
  final String storeName;
  final String status;
  final int totalAmount;
  final String orderNumber;
  final String createdAt;

  const OrderResponse({
    required this.orderId,
    required this.storeName,
    required this.status,
    required this.totalAmount,
    required this.orderNumber,
    required this.createdAt,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: (json['orderId'] as num).toInt(),
      storeName: json['storeName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num).toInt(),
      orderNumber: json['orderNumber'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
