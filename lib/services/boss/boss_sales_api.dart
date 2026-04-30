import 'package:dio/dio.dart';

class BossSalesApi {
  const BossSalesApi(this._dio);

  final Dio _dio;

  Future<dynamic> getMonthlySales({
    required int year,
    required int month,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/boss/sales/monthly',
      queryParameters: {'year': year, 'month': month},
    );
    return response.data;
  }

  Future<dynamic> getDailySales({required String date}) async {
    final response = await _dio.get<dynamic>(
      '/api/boss/sales/daily',
      queryParameters: {'date': date},
    );
    return response.data;
  }
}
