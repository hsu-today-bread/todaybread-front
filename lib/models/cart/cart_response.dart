import 'cart_item_response.dart';

class CartResponse {
  final String? storeName;
  final String? lastOrderTime;
  final List<CartItemResponse> items;

  const CartResponse({
    this.storeName,
    this.lastOrderTime,
    required this.items,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return CartResponse(
      storeName: json['storeName'] as String?,
      lastOrderTime: json['lastOrderTime'] as String?,
      items: rawItems
          .map((e) => CartItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
