import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';


import 'package:todaybread/models/users/user_register_request.dart';
import 'package:todaybread/models/users/user_register_response.dart';

part 'login_api.g.dart';

@RestApi()
abstract class LoginApi {
  factory LoginApi(Dio dio, {String baseUrl}) = _LoginApi;

  /// 회원가입
  @POST('/api/user/register')
  Future<UserRegisterResponse> register(
      @Body() UserRegisterRequest request,
      );

  /// 이메일 중복 확인
  @GET('/api/user/exist/email')
  Future<bool> checkEmail(
      @Query('value') String email,
      );

  /// 전화번호 중복 확인
  @GET('/api/user/exist/phone')
  Future<bool> checkPhone(
      @Query('value') String phone,
      );
}