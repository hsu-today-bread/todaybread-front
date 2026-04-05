import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:retrofit/retrofit.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';

part 'bread_api.g.dart';

/// 메뉴 관련 백엔드 엔드포인트 정의입니다.
///
/// 구현체는 retrofit 생성 파일 [bread_api.g.dart]가 담당합니다.
@RestApi()
abstract class BreadApi {
  factory BreadApi(Dio dio, {String baseUrl}) = _BreadApi;

  @GET('/api/boss/bread')
  Future<List<BreadCommonResponse>> getMyBreads();

  @MultiPart()
  @POST('/api/boss/bread')
  Future<BreadCommonResponse> createBread(
    @Part(name: 'request', contentType: 'application/json') File request,
    @Part(name: 'image') File? image,
  );
}
