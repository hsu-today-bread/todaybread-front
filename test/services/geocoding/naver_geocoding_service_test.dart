import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todaybread/services/geocoding/naver_geocoding_service.dart';

void main() {
  group('NaverGeocodingClient', () {
    test('sends required headers and parses address results', () async {
      late RequestOptions capturedOptions;
      final adapter = _FakeAdapter((options) {
        capturedOptions = options;
        return _jsonResponse(200, {
          'status': 'OK',
          'addresses': [
            {
              'roadAddress': '경기도 성남시 분당구 불정로 6',
              'jibunAddress': '경기도 성남시 분당구 정자동 178-1',
              'x': '127.1052133',
              'y': '37.3595316',
            },
          ],
        });
      });
      final client = _client(adapter);

      final results = await client.search(' 분당구 불정로 6 ');

      expect(capturedOptions.uri.path, '/map-geocode/v2/geocode');
      expect(capturedOptions.queryParameters['query'], '분당구 불정로 6');
      expect(capturedOptions.headers['X-NCP-APIGW-API-KEY-ID'], 'client-id');
      expect(capturedOptions.headers['X-NCP-APIGW-API-KEY'], 'client-secret');
      expect(capturedOptions.headers['Accept'], 'application/json');
      expect(results, hasLength(1));
      expect(results.single.displayAddress, '경기도 성남시 분당구 불정로 6');
      expect(results.single.latitude, 37.3595316);
      expect(results.single.longitude, 127.1052133);
    });

    test('returns empty list for an empty query without requesting', () async {
      var callCount = 0;
      final adapter = _FakeAdapter((options) {
        callCount += 1;
        return _jsonResponse(200, {'status': 'OK', 'addresses': []});
      });
      final client = _client(adapter);

      final results = await client.search('   ');

      expect(results, isEmpty);
      expect(callCount, 0);
    });

    test('fails before requesting when credentials are missing', () async {
      var callCount = 0;
      final adapter = _FakeAdapter((options) {
        callCount += 1;
        return _jsonResponse(200, {'status': 'OK', 'addresses': []});
      });
      final client = _client(adapter, clientSecret: '');

      expect(
        () => client.search('분당구 불정로 6'),
        throwsA(
          isA<GeocodingException>().having(
            (error) => error.type,
            'type',
            GeocodingErrorType.missingCredentials,
          ),
        ),
      );
      expect(callCount, 0);
    });

    test(
      'returns empty list only for a successful empty address result',
      () async {
        final adapter = _FakeAdapter((options) {
          return _jsonResponse(200, {'status': 'OK', 'addresses': []});
        });
        final client = _client(adapter);

        final results = await client.search('없는 주소');

        expect(results, isEmpty);
      },
    );

    test('maps 401 to unauthorized', () async {
      final adapter = _FakeAdapter((options) {
        return _jsonResponse(401, {
          'error': {'code': '200', 'message': 'Authentication Failed'},
        });
      });
      final client = _client(adapter);

      expect(
        () => client.search('분당구 불정로 6'),
        throwsA(
          isA<GeocodingException>().having(
            (error) => error.type,
            'type',
            GeocodingErrorType.unauthorized,
          ),
        ),
      );
    });

    test('maps API deny response to apiDenied', () async {
      final adapter = _FakeAdapter((options) {
        return _jsonResponse(403, {
          'error': {'code': '403', 'message': 'API deny'},
        });
      });
      final client = _client(adapter);

      expect(
        () => client.search('분당구 불정로 6'),
        throwsA(
          isA<GeocodingException>().having(
            (error) => error.type,
            'type',
            GeocodingErrorType.apiDenied,
          ),
        ),
      );
    });

    test('maps plain API deny body to apiDenied', () async {
      final adapter = _FakeAdapter((options) {
        return ResponseBody.fromString('API deny', 403);
      });
      final client = _client(adapter);

      expect(
        () => client.search('분당구 불정로 6'),
        throwsA(
          isA<GeocodingException>().having(
            (error) => error.type,
            'type',
            GeocodingErrorType.apiDenied,
          ),
        ),
      );
    });

    test('maps 429 to quotaExceeded', () async {
      final adapter = _FakeAdapter((options) {
        return _jsonResponse(429, {
          'error': {'code': '429', 'message': 'Quota Exceed'},
        });
      });
      final client = _client(adapter);

      expect(
        () => client.search('분당구 불정로 6'),
        throwsA(
          isA<GeocodingException>().having(
            (error) => error.type,
            'type',
            GeocodingErrorType.quotaExceeded,
          ),
        ),
      );
    });
  });
}

NaverGeocodingClient _client(
  _FakeAdapter adapter, {
  String clientId = 'client-id',
  String clientSecret = 'client-secret',
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://maps.apigw.ntruss.com',
      validateStatus: (_) => true,
    ),
  )..httpClientAdapter = adapter;

  return NaverGeocodingClient(
    clientId: clientId,
    clientSecret: clientSecret,
    dio: dio,
  );
}

ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> data) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _FakeAdapter implements HttpClientAdapter {
  final FutureOr<ResponseBody> Function(RequestOptions options) handler;

  const _FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
