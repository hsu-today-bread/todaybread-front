import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

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

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException(message: '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException(message: '서버에 연결할 수 없습니다. 네트워크 상태를 확인해주세요.');
    }

    return ApiException(message: '요청 처리 중 오류가 발생했습니다.');
  }

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
