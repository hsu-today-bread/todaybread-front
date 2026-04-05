import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:todaybread/models/users/user_login_request.dart';
import 'package:todaybread/models/users/user_login_response.dart';

import 'package:todaybread/models/users/user_register_request.dart';
import 'package:todaybread/models/users/user_register_response.dart';

import 'package:todaybread/models/users/user_find_email_response.dart';
import 'package:todaybread/models/users/verify_identity_response.dart';
import 'package:todaybread/models/users/reset_password_request.dart';
import 'package:todaybread/models/users/reset_password_response.dart';

part 'login_api.g.dart';

/// 로그인/회원가입 관련 REST API 정의입니다.
///
/// Retrofit이 이 인터페이스를 기반으로 실제 HTTP 클라이언트를 생성합니다.
@RestApi()
abstract class LoginApi {
  /// [dio]와 선택 [baseUrl]로 API 인스턴스를 생성합니다.
  factory LoginApi(Dio dio, {String baseUrl}) = _LoginApi;

  /// 회원가입 요청을 전송합니다.

  @POST('/api/user/register')
  Future<UserRegisterResponse> register(
      @Body() UserRegisterRequest request,
      );

  /// 이메일 중복 여부를 확인합니다.

  @GET('/api/user/exist/email')
  Future<bool> checkEmail(
      @Query('value') String email,
      );

  /// 닉네임 중복 여부를 확인합니다.

  @GET('/api/user/exist/nickname')
  Future<bool> checkNickname(
      @Query('value') String nickname,
      );

  /// 전화번호 중복 여부를 확인합니다.

  @GET('/api/user/exist/phone')
  Future<bool> checkPhone(
      @Query('value') String phone,
      );

  /// 로그인 요청을 전송합니다.

  @POST('/api/user/login')
  Future<UserLoginResponse> login(
      @Body() UserLoginRequest request,
      );

  /// 전화번호로 이메일을 찾습니다.

  @GET('/api/user/find-email')
  Future<UserFindEmailResponse> findEmail(
      @Query('phone') String phone,
      );

  /// 이메일과 전화번호로 본인인증을 합니다.

  @GET('/api/user/verify-identity')
  Future<VerifyIdentityResponse> verifyIdentity(
      @Query('phone') String phone,
      @Query('email') String email,
      );

  /// 비밀번호를 재설정합니다.

  @POST('/api/user/reset-password')
  Future<ResetPasswordResponse> resetPassword(
      @Body() ResetPasswordRequest request,
      );
}
