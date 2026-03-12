import 'package:dio/dio.dart';
import 'api_exception.dart';

/// 앱 전역에서 사용하는 Dio HTTP 클라이언트입니다.
///
/// 기본 URL, 타임아웃, 공통 헤더와 에러 인터셉터를 구성합니다.
class DioClient {
  /// 외부 생성 방지를 위한 private 생성자입니다.
  DioClient._();

  /// 앱 내에서 하나만 사용하는 Dio 싱글턴 인스턴스입니다.
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),

  )..interceptors.addAll([
    /// 개발 중 요청/응답 로그를 출력합니다.
    LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
    ),
    InterceptorsWrapper(
      onError: (error, handler) {
        /// DioException을 공통 ApiException으로 변환해 상위 계층에서 일관 처리합니다.
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

  /// 공통으로 재사용할 Dio 인스턴스를 반환합니다.
  static Dio get instance => _dio;
}
