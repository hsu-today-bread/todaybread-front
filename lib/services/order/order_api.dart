import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:todaybread/models/order/order_list_response.dart';

part 'order_api.g.dart';

@RestApi()
abstract class OrderApi {
  factory OrderApi(Dio dio, {String baseUrl}) = _OrderApi;

  @GET('/api/orders')
  Future<OrderListResponse> getOrders(
    @Query('page') int page,
    @Query('size') int size,
  );
}
