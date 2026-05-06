/// 주문 생성/상세 응답 DTO
class OrderDetailResponse {
  final int orderId;
  final String storeName;
  final String status;
  final int totalAmount;
  final String orderNumber;

  const OrderDetailResponse({
    required this.orderId,
    required this.storeName,
    required this.status,
    required this.totalAmount,
    required this.orderNumber,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      orderId: (json['orderId'] as num).toInt(),
      storeName: json['storeName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num).toInt(),
      orderNumber: json['orderNumber'] as String? ?? '',
    );
  }
}
