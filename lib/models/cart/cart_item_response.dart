class CartItemResponse {
  final int cartItemId;
  final int breadId;
  final String breadName;
  final String description;
  final int quantity;
  final String? imageUrl;
  final int salePrice;

  const CartItemResponse({
    required this.cartItemId,
    required this.breadId,
    required this.breadName,
    required this.description,
    required this.quantity,
    this.imageUrl,
    required this.salePrice,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      cartItemId: json['cartItemId'] as int,
      breadId: json['breadId'] as int,
      breadName: json['breadName'] as String,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
      salePrice: json['salePrice'] as int,
    );
  }
}
