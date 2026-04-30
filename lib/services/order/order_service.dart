import 'package:todaybread/models/order/order_list_response.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'order_api.dart';

class OrderService {
  OrderService._();

  static final OrderService instance = OrderService._();

  final OrderApi _api = OrderApi(DioClient.instance);

  Future<OrderListResponse> getOrders({int page = 0, int size = 20}) =>
      _api.getOrders(page, size);
}
