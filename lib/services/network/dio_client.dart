import 'package:dio/dio.dart';
import 'api_exception.dart';

class DioClient {
  DioClient._();

  ///앱 내에 하나만 존재->싱글턴 구조
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),

  )..interceptors.addAll([
    LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
    ),
    InterceptorsWrapper(
      onError: (error, handler) {
        final apiError = ApiException.fromDio(error);
        handler.reject(
          error.copyWith(
            error: apiError,
            message: apiError.message,
          ),
        );
      },
    ),
  ]);
  static Dio get instance => _dio;
}
