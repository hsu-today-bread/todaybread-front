import 'package:dio/dio.dart';

class DioClient {
  DioClient._();

  //앱 내에 하나만 존재->싱글턴 구조
  static final Dio _dio = Dio(
    BaseOptions(
      /*baseUrl+api에 /api/auth/login과 합쳐짐
      connectTimeout: 서버연결을 몇초 기다릴지
      receiveTimeout: 응답을 몇 초 기다릴지
       */
      baseUrl: '',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),

  )..interceptors.add(
    LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
    ),
  );
  static Dio get instance => _dio;
}
