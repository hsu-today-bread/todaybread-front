import 'package:dio/dio.dart';

class BossOrderApi {
  const BossOrderApi(this._dio);

  final Dio _dio;

  Future<dynamic> getOrders({required int page, required int size}) async {
    final response = await _dio.get<dynamic>(
      '/api/boss/orders',
      queryParameters: {'page': page, 'size': size},
    );
    return response.data;
  }

  Future<void> confirmPickup(int orderId) async {
    await _dio.post<void>('/api/boss/orders/$orderId/pickup');
  }
}
