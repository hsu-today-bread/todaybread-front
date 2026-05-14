class CartAddRequest {
  final int breadId;
  final int quantity;

  const CartAddRequest({required this.breadId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'breadId': breadId,
        'quantity': quantity,
      };
}
