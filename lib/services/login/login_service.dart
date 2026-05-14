import 'package:todaybread/models/users/user_login_request.dart';
import 'package:todaybread/models/users/user_login_response.dart';
import 'package:todaybread/models/users/user_register_request.dart';
import 'package:todaybread/models/users/user_register_response.dart';
import 'package:todaybread/models/users/user_find_email_response.dart';
import 'package:todaybread/models/users/verify_identity_response.dart';
import 'package:todaybread/models/users/reset_password_request.dart';
import 'package:todaybread/models/users/reset_password_response.dart';
import '../network/dio_client.dart';
import 'login_api.dart';

/// 로그인/회원가입 도메인 서비스입니다.
///
/// 화면 레이어에서 API 호출 상세를 숨기고, 인증 관련 기능을 제공합니다.
class LoginService {
  /// 외부 생성 방지를 위한 private 생성자입니다.
  LoginService._();

  /// 앱 전역에서 재사용하는 싱글턴 인스턴스입니다.
  static final LoginService instance = LoginService._();

  /// Retrofit 기반 API 클라이언트입니다.
  final LoginApi _api = LoginApi(DioClient.instance);

  /// 회원가입을 요청합니다.

  Future<UserRegisterResponse> register(UserRegisterRequest request) async {
    return await _api.register(request);
  }

  /// 이메일 중복 여부를 조회합니다.

  Future<bool> checkEmail(String email) async {
    return await _api.checkEmail(email);
  }

  /// 닉네임 중복 여부를 조회합니다.

  Future<bool> checkNickname(String nickname) async {
    return await _api.checkNickname(nickname);
  }

  /// 전화번호 중복 여부를 조회합니다.
  Future<bool> checkPhone(String phone) async {
    return await _api.checkPhone(phone);
  }

  /// 로그인을 요청합니다.

  Future<UserLoginResponse> login(UserLoginRequest request) async {
    return await _api.login(request);
  }

  /// 전화번호로 이메일을 찾습니다.

  Future<UserFindEmailResponse> findEmail(String phone) async {
    return await _api.findEmail(phone);
  }

  /// 이메일과 전화번호로 본인인증을 합니다.

  Future<VerifyIdentityResponse> verifyIdentity(
      String phone, String email) async {
    return await _api.verifyIdentity(phone, email);
  }

  /// 비밀번호를 재설정합니다.

  Future<ResetPasswordResponse> resetPassword(
      ResetPasswordRequest request) async {
    return await _api.resetPassword(request);
  }
}
