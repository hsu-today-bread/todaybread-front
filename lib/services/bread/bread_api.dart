import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:retrofit/retrofit.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/models/bread/bread_detail_response.dart';
import 'package:todaybread/models/bread/nearyby_bread_response.dart';

part 'bread_api.g.dart';

/// 메뉴 관련 백엔드 엔드포인트 정의입니다.
///
/// 구현체는 retrofit 생성 파일 [bread_api.g.dart]가 담당합니다.
@RestApi()
abstract class BreadApi {
  factory BreadApi(Dio dio, {String baseUrl}) = _BreadApi;

  @GET('/api/bread/nearby')
  Future<List<NearbyBreadResponse>> getNearbyBreads(
    @Query('lat') double lat,
    @Query('lng') double lng,
    @Query('radius') int radius,
    @Query('sort') String sort,
  );

  @GET('/api/bread/detail/{breadId}')
  Future<BreadDetailResponse> getBreadDetail(@Path('breadId') int breadId);

  @GET('/api/boss/bread')
  Future<List<BreadCommonResponse>> getMyBreads();

  @MultiPart()
  @POST('/api/boss/bread')
  Future<BreadCommonResponse> createBread(
    @Part(name: 'request', contentType: 'application/json') File request,
    @Part(name: 'image') File? image,
  );

  @PATCH('/api/boss/bread/{breadId}/stock')
  Future<void> updateBreadStock(
    @Path('breadId') int breadId,
    @Body() Map<String, dynamic> request,
  );
}
