import 'order_response.dart';

/// Spring Page 형식의 주문 목록 응답 DTO
class OrderListResponse {
  final List<OrderResponse> content;
  final int totalElements;
  final int totalPages;
  final bool last;

  const OrderListResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}
