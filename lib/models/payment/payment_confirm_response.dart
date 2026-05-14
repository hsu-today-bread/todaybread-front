/// 토스 결제 승인 확정 응답 DTO
class PaymentConfirmResponse {
  final int paymentId;
  final int orderId;
  final int amount;
  final String status;
  final String? paidAt;
  final String? method;

  const PaymentConfirmResponse({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.status,
    this.paidAt,
    this.method,
  });

  factory PaymentConfirmResponse.fromJson(Map<String, dynamic> json) {
    return PaymentConfirmResponse(
      paymentId: (json['paymentId'] as num).toInt(),
      orderId: (json['orderId'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
      status: json['status'] as String,
      paidAt: json['paidAt'] as String?,
      method: json['method'] as String?,
    );
  }
}
