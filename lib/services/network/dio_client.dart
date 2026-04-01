import 'package:dio/dio.dart';

import '../auth/auth_service.dart';
import '../auth/auth_token_storage.dart';
import 'api_exception.dart';

/// 앱 전역에서 사용하는 Dio HTTP 클라이언트입니다.
///
/// 기본 URL, 타임아웃, 공통 헤더와 에러 인터셉터를 구성합니다.
class DioClient {
  /// 외부 생성 방지를 위한 private 생성자입니다.
  DioClient._();

  static const String _baseUrl = 'http://10.0.2.2:8080';
  static String get baseUrl => _baseUrl;

  /// 앱 내에서 하나만 사용하는 Dio 싱글턴 인스턴스입니다.
  static final Dio _dio = createPlainDio()
    ..interceptors.addAll([
      /// 개발 중 요청/응답 로그를 출력합니다.
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 로그인 이후 보호 API는 access token을 자동으로 헤더에 붙입니다.
          final accessToken = await AuthTokenStorage.instance.readAccessToken();
          if (accessToken != null &&
              accessToken.isNotEmpty &&
              options.headers['Authorization'] == null &&
              options.path != '/api/auth/reissue') {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          _handleError(error, handler);
        },
      ),
    ]);

  /// 인터셉터가 없는 순수 Dio를 생성합니다.
  ///
  /// refresh token 재발급 요청은 여기서 만든 인스턴스를 사용합니다.
  static Dio createPlainDio() {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  /// 공통으로 재사용할 Dio 인스턴스를 반환합니다.
  static Dio get instance => _dio;

  static Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final apiError = ApiException.fromDio(error);
    final requestOptions = error.requestOptions;

    // access token 만료일 때만 한 번 재발급 후 원래 요청을 재시도합니다.
    if (error.response?.statusCode == 401 &&
        apiError.code == 'AUTH_001' &&
        requestOptions.extra['retried'] != true &&
        requestOptions.path != '/api/auth/reissue') {
      try {
        final tokens = await AuthService.instance.reissueTokens();
        if (tokens != null) {
          requestOptions.headers['Authorization'] =
              'Bearer ${tokens.accessToken}';
          requestOptions.extra['retried'] = true;
          final response = await _dio.fetch(requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (_) {
        // 재발급 실패 시에는 아래 공통 에러 처리로 내려갑니다.
      }
    }

    handler.reject(error.copyWith(error: apiError, message: apiError.message));
  }
}
