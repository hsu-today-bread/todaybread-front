import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:todaybread/models/store/store_common_request.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_status_response.dart';

part 'store_api.g.dart';

/// 가게 관련 REST API 정의입니다.
@RestApi()
abstract class StoreApi {
  factory StoreApi(Dio dio, {String baseUrl}) = _StoreApi;

  @GET('/api/store/status')
  Future<StoreStatusResponse> getStatus();

  @POST('/api/store/add-store')
  Future<StoreCommonResponse> createStore(@Body() StoreCommonRequest request);

  @PUT('/api/store/update-store')
  Future<StoreCommonResponse> updateStore(@Body() StoreCommonRequest request);
}
