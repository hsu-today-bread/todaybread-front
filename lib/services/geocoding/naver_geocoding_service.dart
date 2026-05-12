import 'package:dio/dio.dart';

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

  static final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://maps.apigw.ntruss.com',
      headers: {
        'X-NCP-APIGW-API-KEY-ID': _clientId,
        'X-NCP-APIGW-API-KEY': _clientSecret,
      },
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static Future<List<GeocodingResult>> search(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return [];

    final response = await _dio.get(
      '/map-geocode/v2/geocode',
      queryParameters: {'query': normalizedQuery},
    );

    final addresses = response.data['addresses'] as List<dynamic>? ?? [];
    return addresses
        .map((e) => GeocodingResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
