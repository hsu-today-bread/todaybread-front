import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/auth/token_response.dart';
import '../../models/users/user_login_response.dart';
import '../network/api_exception.dart';
import '../network/dio_client.dart';
import 'auth_token_storage.dart';

/// JWT 인증 관련 공통 동작을 모아 둔 서비스입니다.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final AuthTokenStorage _tokenStorage = AuthTokenStorage.instance;

  /// 로그인 성공 직후 받은 토큰을 저장합니다.
  Future<void> saveLoginTokens(UserLoginResponse response) async {
    if (response.accessToken == null || response.refreshToken == null) {
      debugPrint(
        '[AuthService] saveLoginTokens skipped access=${response.accessToken != null} refresh=${response.refreshToken != null}',
      );
      return;
    }

    debugPrint('[AuthService] saveLoginTokens start');
    await _tokenStorage.saveTokens(
      accessToken: response.accessToken!,
      refreshToken: response.refreshToken!,
    );
    debugPrint('[AuthService] saveLoginTokens done');
  }

  /// 저장된 토큰을 모두 비웁니다.
  Future<void> clearTokens() async {
    await _tokenStorage.clearTokens();
  }

  /// 스플래시 진입 시 저장된 access token이 실제로 유효한지 확인합니다.
  ///
  /// access token이 살아 있으면 그대로 true,
  /// access token이 만료되었으면 refresh token으로 재발급을 시도합니다.
  ///
  Future<bool> restoreSessionIfPossible() async {
    debugPrint('[AuthService] restoreSessionIfPossible start');
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();

    if ((accessToken == null || accessToken.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      debugPrint('[AuthService] no stored tokens');
      return false;
    }

    try {
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('[AuthService] access token missing, trying reissue');
        final reissuedTokens = await reissueTokens();
        debugPrint(
          '[AuthService] reissue result with missing access=${reissuedTokens != null}',
        );
        return reissuedTokens != null;
      }

      final payload = _parseJwtPayload(accessToken);
      final exp = payload['exp'];
      if (exp is! num) {
        debugPrint('[AuthService] invalid exp in access token, trying reissue');
        final reissuedTokens = await reissueTokens();
        debugPrint(
          '[AuthService] reissue result after invalid exp=${reissuedTokens != null}',
        );
        return reissuedTokens != null;
      }

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      final isValid = expiresAt.isAfter(DateTime.now());
      debugPrint(
        '[AuthService] access token expiresAt=$expiresAt now=${DateTime.now()} isValid=$isValid',
      );

      if (isValid) {
        debugPrint('[AuthService] access token still valid');
        return true;
      }

      // access token이 만료된 경우에는 refresh token으로 새 토큰을 받아 로그인을 유지합니다.
      debugPrint('[AuthService] access token expired, trying reissue');
      final reissuedTokens = await reissueTokens();
      debugPrint(
        '[AuthService] reissue result after expiration=${reissuedTokens != null}',
      );
      return reissuedTokens != null;
    } catch (error) {
      debugPrint('[AuthService] restoreSessionIfPossible failed: $error');
      await clearTokens();
      return false;
    }
  }

  /// refresh token으로 새로운 토큰 쌍을 발급받습니다.
  ///
  /// 재발급 요청은 별도 Dio 인스턴스로 보내서,
  /// 현재 인증 인터셉터와 충돌하지 않게 분리합니다.
  Future<TokenResponse?> reissueTokens() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('[AuthService] reissueTokens skipped: no refresh token');
      return null;
    }

    final Dio refreshDio = DioClient.createPlainDio();

    try {
      debugPrint('[AuthService] reissueTokens request start');
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/api/auth/reissue',
        data: {'refreshToken': refreshToken},
      );

      final body = response.data;
      if (body == null) {
        return null;
      }

      final tokens = TokenResponse.fromJson(body);
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      debugPrint('[AuthService] reissueTokens success');
      return tokens;
    } on DioException catch (error) {
      // refresh token까지 만료/불량이면 기존 토큰은 더 이상 의미가 없으므로 정리합니다.
      debugPrint(
        '[AuthService] reissueTokens failed status=${error.response?.statusCode} data=${error.response?.data}',
      );
      await clearTokens();
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _parseJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT format');
    }

    final normalized = base64Url.normalize(parts[1]);
    final payloadString = utf8.decode(base64Url.decode(normalized));
    final payload = jsonDecode(payloadString);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Invalid JWT payload');
    }
    return payload;
  }
}
