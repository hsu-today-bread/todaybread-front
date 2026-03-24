import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:todaybread/models/users/user_update_request.dart';
import 'package:todaybread/models/users/user_update_response.dart';

part 'user_api.g.dart';

/// 사용자 정보 관련 REST API 정의입니다.
@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String baseUrl}) = _UserApi;

  /// 사용자 프로필을 수정합니다.
  @PATCH('/api/user/update-profile')
  Future<UserUpdateResponse> updateProfile(@Body() UserUpdateRequest request);
}
