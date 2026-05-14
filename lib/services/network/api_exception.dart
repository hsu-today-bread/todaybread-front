import 'package:dio/dio.dart';

/// API 요청 중 발생한 예외를 표현하는 클래스입니다.
///
/// [message] 사용자에게 표시할 메시지
/// [code] 서버에서 전달한 비즈니스 에러 코드
/// [statusCode] HTTP 상태 코드
class ApiException implements Exception {

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
  });


  final String message;
  final String? code;
  final int? statusCode;


  /// 서버의 에러 응답(JSON)이 있으면 메시지/코드를 우선 사용하고,
  /// 그 외에 네트워크/타임아웃 등 전송 오류는 사용자 메시지로 매핑합니다.
  static ApiException fromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      final code = data['code']?.toString();

      if (message != null && message.isNotEmpty) {
        return ApiException(
          message: message,
          code: code,
          statusCode: error.response?.statusCode,
        );
      }
    }

    /// 서버 응답 지연 메시지
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException(message: '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.');
    }


    /// 네트워크 연결 오류
    if (error.type == DioExceptionType.connectionError) {
      return ApiException(message: '서버에 연결할 수 없습니다. 네트워크 상태를 확인해주세요.');
    }

    return ApiException(message: '요청 처리 중 오류가 발생했습니다.');
  }

  /// 임의 예외 객체에서 사용자 메시지를 안전하게 추출합니다.
  static String messageFrom(Object error) {
    if (error is ApiException) return error.message;
    if (error is DioException) {
      final inner = error.error;
      if (inner is ApiException) return inner.message;
      return fromDio(error).message;
    }
    return '알 수 없는 오류가 발생했습니다.';
  }
}
