import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum GeocodingErrorType {
  missingCredentials,
  unauthorized,
  forbidden,
  apiDenied,
  quotaExceeded,
  badRequest,
  invalidResponse,
  network,
  unknown,
}

class GeocodingException implements Exception {
  final GeocodingErrorType type;
  final String message;
  final int? statusCode;
  final String? apiCode;

  const GeocodingException({
    required this.type,
    required this.message,
    this.statusCode,
    this.apiCode,
  });

  @override
  String toString() {
    final details = [
      if (statusCode != null) 'statusCode=$statusCode',
      if (apiCode != null && apiCode!.isNotEmpty) 'apiCode=$apiCode',
    ].join(', ');
    return details.isEmpty
        ? 'GeocodingException($type): $message'
        : 'GeocodingException($type, $details): $message';
  }
}

class GeocodingResult {
  final String roadAddress;
  final String jibunAddress;
  final double latitude;
  final double longitude;

  const GeocodingResult({
    required this.roadAddress,
    required this.jibunAddress,
    required this.latitude,
    required this.longitude,
  });

  /// 사용자에게 표시할 대표 주소 (도로명 우선, 없으면 지번)
  String get displayAddress =>
      roadAddress.isNotEmpty ? roadAddress : jibunAddress;

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      roadAddress: json['roadAddress'] as String? ?? '',
      jibunAddress: json['jibunAddress'] as String? ?? '',
      latitude: double.parse(json['y'] as String),
      longitude: double.parse(json['x'] as String),
    );
  }
}

class NaverGeocodingService {
  static const _clientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');
  static const _clientSecret = String.fromEnvironment(
    'NAVER_MAP_CLIENT_SECRET',
  );

  static final NaverGeocodingClient _client = NaverGeocodingClient(
    clientId: _clientId,
    clientSecret: _clientSecret,
  );

  static Future<List<GeocodingResult>> search(String query) async {
    return _client.search(query);
  }
}

@visibleForTesting
class NaverGeocodingClient {
  final String clientId;
  final String clientSecret;
  final Dio _dio;

  NaverGeocodingClient({
    required String clientId,
    required String clientSecret,
    Dio? dio,
  }) : clientId = clientId.trim(),
       clientSecret = clientSecret.trim(),
       _dio = dio ?? _createDio();

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://maps.apigw.ntruss.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        validateStatus: (_) => true,
      ),
    );
  }

  Future<List<GeocodingResult>> search(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return [];

    _ensureCredentials();

    late final Response<dynamic> response;
    try {
      response = await _dio.get(
        '/map-geocode/v2/geocode',
        queryParameters: {'query': normalizedQuery},
        options: Options(
          headers: {
            'X-NCP-APIGW-API-KEY-ID': clientId,
            'X-NCP-APIGW-API-KEY': clientSecret,
            'Accept': 'application/json',
          },
        ),
      );
    } on DioException catch (error) {
      _debugLog('network error=${error.type}');
      throw const GeocodingException(
        type: GeocodingErrorType.network,
        message: '주소 검색 서버에 연결하지 못했습니다.',
      );
    }

    _debugLog(
      'httpStatus=${response.statusCode} error=${_extractErrorMessage(response.data)}',
    );

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    if (statusCode != 200) {
      throw _exceptionFromResponse(statusCode, data);
    }

    if (data is! Map<String, dynamic>) {
      throw const GeocodingException(
        type: GeocodingErrorType.invalidResponse,
        message: '주소 검색 응답 형식이 올바르지 않습니다.',
      );
    }

    final responseStatus = data['status'] as String?;
    if (responseStatus != null && responseStatus != 'OK') {
      throw _exceptionFromResponse(statusCode, data);
    }

    final addresses = data['addresses'];
    if (addresses is! List<dynamic>) {
      throw const GeocodingException(
        type: GeocodingErrorType.invalidResponse,
        message: '주소 검색 결과 형식이 올바르지 않습니다.',
      );
    }

    return addresses
        .map((e) => GeocodingResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _ensureCredentials() {
    if (clientId.isEmpty || clientSecret.isEmpty) {
      _debugLog('missing credentials');
      throw const GeocodingException(
        type: GeocodingErrorType.missingCredentials,
        message: 'Naver Geocoding 인증 정보가 설정되지 않았습니다.',
      );
    }
  }

  GeocodingException _exceptionFromResponse(int statusCode, dynamic data) {
    final apiCode = _extractErrorCode(data);
    final apiMessage = _extractErrorMessage(data);
    final normalizedMessage = apiMessage.toLowerCase();

    var type = GeocodingErrorType.unknown;
    if (statusCode == 400) {
      type = GeocodingErrorType.badRequest;
    } else if (statusCode == 401) {
      type = GeocodingErrorType.unauthorized;
    } else if (statusCode == 403) {
      type = GeocodingErrorType.forbidden;
    } else if (statusCode == 429) {
      type = GeocodingErrorType.quotaExceeded;
    }

    if (normalizedMessage.contains('api deny') ||
        normalizedMessage.contains('denied')) {
      type = GeocodingErrorType.apiDenied;
    }

    return GeocodingException(
      type: type,
      statusCode: statusCode,
      apiCode: apiCode.isEmpty ? null : apiCode,
      message: apiMessage.isEmpty ? '주소 검색 요청이 실패했습니다.' : apiMessage,
    );
  }

  String _extractErrorCode(dynamic data) {
    if (data is! Map<String, dynamic>) return '';
    final error = data['error'];
    if (error is Map<String, dynamic>) {
      return (error['code'] ?? error['errorCode'] ?? '').toString();
    }
    return (data['code'] ?? data['errorCode'] ?? data['status'] ?? '')
        .toString();
  }

  String _extractErrorMessage(dynamic data) {
    if (data is String) return data;
    if (data is! Map<String, dynamic>) return '';
    final error = data['error'];
    if (error is String) return error;
    if (error is Map<String, dynamic>) {
      return (error['message'] ?? error['errorMessage'] ?? '').toString();
    }
    return (data['message'] ?? data['errorMessage'] ?? '').toString();
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[Geocoding] $message');
    }
  }
}
