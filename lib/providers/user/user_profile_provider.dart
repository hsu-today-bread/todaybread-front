import 'package:flutter/material.dart';

import 'package:todaybread/models/users/user_update_request.dart';
import 'package:todaybread/models/users/user_update_response.dart';
import 'package:todaybread/services/login/login_service.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/user/user_service.dart';

/// 사용자 프로필 상태를 관리하는 Provider입니다.
class UserProfileProvider extends ChangeNotifier {
  final UserService _service = UserService.instance;
  final LoginService _loginService = LoginService.instance;

  bool isLoading = false;
  String? errorMessage;
  UserUpdateResponse? profile;

  /// 내 프로필을 수정합니다.
  Future<UserUpdateResponse?> updateProfile({
    required String nickname,
    required String name,
    required String phone,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.updateProfile(
        UserUpdateRequest(nickname: nickname, name: name, phone: phone),
      );

      profile = response;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 닉네임 중복 여부를 확인합니다.
  Future<bool> checkNickname(String nickname) async {
    try {
      errorMessage = null;
      return await _loginService.checkNickname(nickname);
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      return false;
    }
  }

  /// 전화번호 중복 여부를 확인합니다.
  Future<bool> checkPhone(String phone) async {
    try {
      errorMessage = null;
      return await _loginService.checkPhone(phone);
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      return false;
    }
  }
}
