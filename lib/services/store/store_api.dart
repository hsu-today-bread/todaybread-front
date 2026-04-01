import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_image_response.dart';
import 'package:todaybread/models/store/store_info_response.dart';
import 'package:todaybread/models/store/store_status_response.dart';

part 'store_api.g.dart';

@RestApi()
abstract class StoreApi {
  factory StoreApi(Dio dio, {String baseUrl}) = _StoreApi;

  @GET('/api/boss/store/status')
  Future<StoreStatusResponse> getStatus();

  @GET('/api/boss/store')
  Future<StoreInfoResponse> getStoreInfo();

  @MultiPart()
  @POST('/api/boss/store')
  Future<StoreInfoResponse> createStore(
    @Part(name: 'request', contentType: 'application/json') File request,
    @Part(name: 'images') List<File> images,
  );

  @PUT('/api/boss/store')
  Future<StoreCommonResponse> updateStore(@Body() Map<String, dynamic> request);

  @MultiPart()
  @PUT('/api/boss/store/images')
  Future<List<StoreImageResponse>> updateImages(
    @Part(name: 'images') List<File> images,
  );
}
