class CartUpdateRequest {
  final int quantity;

  const CartUpdateRequest({required this.quantity});

  Map<String, dynamic> toJson() => {'quantity': quantity};
}
