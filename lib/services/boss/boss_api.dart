import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:todaybread/models/boss/boss_request.dart';
import 'package:todaybread/models/boss/boss_response.dart';

part 'boss_api.g.dart';

/// 사업자 인증 관련 REST API 정의입니다.
@RestApi()
abstract class BossApi {
  factory BossApi(Dio dio, {String baseUrl}) = _BossApi;

  @POST('/api/user/boss-approve')
  Future<BossResponse> approve(@Body() BossRequest request);
}
