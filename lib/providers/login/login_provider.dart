import 'package:flutter/material.dart';

import 'package:todaybread/models/users/user_register_request.dart';
import 'package:todaybread/services/auth/auth_service.dart';
import 'package:todaybread/services/auth/auth_token_storage.dart';
import 'package:todaybread/services/local/user_local_store.dart';
import 'package:todaybread/services/network/api_exception.dart';

import 'package:todaybread/services/login/login_service.dart';

import '../../models/users/user_login_request.dart';
import '../../models/users/user_login_response.dart';

enum UserRole { user, boss, unknown }

/// 로그인/회원가입 화면 상태를 관리하는 Provider입니다.
class AuthProvider extends ChangeNotifier {
  final AuthTokenStorage _tokenStorage = AuthTokenStorage.instance;

  /// API 요청 진행 상태입니다.
  bool isLoading = false;

  /// 마지막 오류 메시지입니다.
  String? errorMessage;

  UserRole role = UserRole.unknown;

  /// 인증 관련 서비스 인스턴스입니다.
  final LoginService _service = LoginService.instance;

  Future<UserLoginResponse?> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.login(
        UserLoginRequest(email: email, password: password),
      );

      if (response.success) {
        await UserLocalStore.saveUser(
          nickname: response.nickname,
          name: response.name,
          phone: response.phone,
        );
        await AuthService.instance.saveLoginTokens(response);
        await refreshRoleFromStoredToken(notify: false);
      }

      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 이메일 중복 여부를 확인합니다.
  Future<bool> checkEmail(String email) async {
    try {
      return await _service.checkEmail(email);
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      return false;
    }
  }

  /// 전화번호 중복 여부를 확인합니다.
  Future<bool> checkPhone(String phone) async {
    try {
      return await _service.checkPhone(phone);
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      return false;
    }
  }

  /// 회원가입을 요청합니다.
  Future<bool> register({
    required String email,
    required String nickname,
    required String name,
    required String password,
    required String phone,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final request = UserRegisterRequest(
        email: email,
        nickname: nickname,
        name: name,
        password: password,
        phone: phone,
      );

      await _service.register(request);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      return false;
    }
  }

  bool get isBoss => role == UserRole.boss;

  Future<void> refreshRoleFromStoredToken({bool notify = true}) async {
    final accessToken = await _tokenStorage.readAccessToken();
    role = _roleFromToken(accessToken);
    if (notify) {
      notifyListeners();
    }
  }

  UserRole _roleFromToken(String? token) {
    if (token == null || token.isEmpty) {
      return UserRole.unknown;
    }

    try {
      final payload = AuthService.instance.parseJwtPayload(token);
      final rawRole = payload['role']?.toString().toUpperCase();
      if (rawRole == 'BOSS') {
        return UserRole.boss;
      }
      if (rawRole == 'USER') {
        return UserRole.user;
      }
    } catch (_) {
      return UserRole.unknown;
    }

    return UserRole.unknown;
  }
}
