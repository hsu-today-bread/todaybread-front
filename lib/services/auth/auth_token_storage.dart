import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 토큰을 안전하게 보관하는 저장소입니다.
///
/// access token은 매 요청 헤더에 사용되고,
/// refresh token은 access token 만료 시 재발급에 사용됩니다.
class AuthTokenStorage {
  AuthTokenStorage._();

  static final AuthTokenStorage instance = AuthTokenStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    debugPrint(
      '[AuthTokenStorage] saveTokens access=${accessToken.length} refresh=${refreshToken.length}',
    );
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    debugPrint(
      '[AuthTokenStorage] readAccessToken exists=${token != null && token.isNotEmpty}',
    );
    return token;
  }

  Future<String?> readRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    debugPrint(
      '[AuthTokenStorage] readRefreshToken exists=${token != null && token.isNotEmpty}',
    );
    return token;
  }

  Future<void> clearTokens() async {
    debugPrint('[AuthTokenStorage] clearTokens');
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
