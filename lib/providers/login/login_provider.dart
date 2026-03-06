import 'package:flutter/material.dart';

import 'package:todaybread/models/users/user_register_request.dart';
import 'package:todaybread/services/network/api_exception.dart';

import 'package:todaybread/services/login/login_service.dart';


class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  final LoginService _service = LoginService.instance;

  /// 이메일 중복 체크
  Future<bool> checkEmail(String email) async {
    try {
      return await _service.checkEmail(email);
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      return false;
    }
  }

  /// 전화번호 중복 체크
  Future<bool> checkPhone(String phone) async {
    try {
      return await _service.checkPhone(phone);
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      return false;
    }
  }

  /// 회원가입
  Future<bool> register({
    required String email,
    required String nickname,
    required String password,
    required String phone,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final request = UserRegisterRequest(
        email: email,
        nickName: nickname,
        password: password,
        phoneNumber: phone,
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
}
