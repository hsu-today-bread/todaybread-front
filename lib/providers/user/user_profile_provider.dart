import 'package:flutter/material.dart';

import 'package:todaybread/models/users/user_update_request.dart';
import 'package:todaybread/models/users/user_update_response.dart';
import 'package:todaybread/services/login/login_service.dart';
import 'package:todaybread/services/local/user_local_store.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/user/user_service.dart';

/// 사용자 프로필 상태를 관리하는 Provider입니다.
class UserProfileProvider extends ChangeNotifier {
  final UserService _service = UserService.instance;
  final LoginService _loginService = LoginService.instance;

  bool isLoading = false;
  String? errorMessage;
  UserUpdateResponse? profile;
  String? _nickname;
  String? _name;
  String? _phone;

  // 화면은 local store를 직접 읽지 않고 이 provider만 보도록 맞췄다.
  // 메모리에 값이 없을 때만 fallback으로 로컬 값을 읽는다.
  String get nickname => _nickname ?? UserLocalStore.getNickname();
  String get name => _name ?? UserLocalStore.getName();
  String get phone => _phone ?? UserLocalStore.getPhone();

  /// 로컬 저장소 기준으로 현재 프로필 상태를 동기화합니다.
  void hydrateFromLocal({bool notify = false}) {
    _nickname = UserLocalStore.getNickname();
    _name = UserLocalStore.getName();
    _phone = UserLocalStore.getPhone();
    if (notify) {
      notifyListeners();
    }
  }

  void clearProfile({bool notify = false}) {
    _nickname = null;
    _name = null;
    _phone = null;
    profile = null;
    errorMessage = null;
    if (notify) {
      notifyListeners();
    }
  }

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

      // 서버 응답 기준으로 provider 메모리 상태도 함께 갱신한다.
      // 실제 Hive 저장은 UserService 내부에서 처리한다.
      profile = response;
      _nickname = response.nickname;
      _name = response.name;
      _phone = response.phone;
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
