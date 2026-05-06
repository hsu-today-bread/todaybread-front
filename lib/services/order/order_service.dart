import 'package:dio/dio.dart';
import 'package:todaybread/models/order/order_detail_response.dart';
import 'package:todaybread/models/order/order_list_response.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'order_api.dart';

class OrderService {
  OrderService._();

  static final OrderService instance = OrderService._();

  final OrderApi _api = OrderApi(DioClient.instance);

  Future<OrderListResponse> getOrders({int page = 0, int size = 20}) =>
      _api.getOrders(page, size);

  /// 장바구니 기반 주문을 생성합니다.
  Future<OrderDetailResponse> createOrderFromCart(String idempotencyKey) async {
    final response = await DioClient.instance.post(
      '/api/orders/cart',
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return OrderDetailResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
