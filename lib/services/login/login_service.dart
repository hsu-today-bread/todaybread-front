import 'package:todaybread/models/users/user_register_request.dart';
import 'package:todaybread/models/users/user_register_response.dart';
import '../network/dio_client.dart';
import 'login_api.dart';

class LoginService {
  LoginService._();

  static final LoginService instance = LoginService._();

  final LoginApi _api = LoginApi(DioClient.instance);

  /// 회원가입
  Future<UserRegisterResponse> register(UserRegisterRequest request) async {
    return await _api.register(request);
  }

  /// 이메일 중복 확인
  Future<bool> checkEmail(String email) async {
    return await _api.checkEmail(email);
  }

  /// 전화번호 중복 확인
  Future<bool> checkPhone(String phone) async {
    return await _api.checkPhone(phone);
  }
}