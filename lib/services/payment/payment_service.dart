import 'package:dio/dio.dart';
import 'package:todaybread/models/payment/payment_confirm_request.dart';
import 'package:todaybread/models/payment/payment_confirm_response.dart';
import 'package:todaybread/services/network/dio_client.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  /// 토스 페이먼츠 Client Key를 조회합니다.
  Future<String> getClientKey() async {
    final response = await DioClient.instance.get('/api/payments/client-key');
    final data = response.data as Map<String, dynamic>;
    return data['clientKey'] as String;
  }

  /// 토스 결제 승인을 확정합니다.
  Future<PaymentConfirmResponse> confirmPayment({
    required String paymentKey,
    required int orderId,
    required int amount,
    required String idempotencyKey,
  }) async {
    final response = await DioClient.instance.post(
      '/api/payments/confirm',
      data: PaymentConfirmRequest(
        paymentKey: paymentKey,
        orderId: orderId,
        amount: amount,
      ).toJson(),
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return PaymentConfirmResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}
