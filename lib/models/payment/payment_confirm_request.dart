/// 토스 결제 승인 확정 요청 DTO
class PaymentConfirmRequest {
  final String paymentKey;
  final int orderId;
  final String tossOrderId;
  final int amount;

  const PaymentConfirmRequest({
    required this.paymentKey,
    required this.orderId,
    required this.tossOrderId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'paymentKey': paymentKey,
    'orderId': orderId,
    'tossOrderId': tossOrderId,
    'amount': amount,
  };
}
