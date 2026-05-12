import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/store/favourite_store_response.dart';
import 'package:todaybread/models/store/nearby_store_response.dart';
import 'package:todaybread/models/store/favourite_store_toggle_response.dart';
import 'package:todaybread/models/store/store_common_request.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_detail_response.dart';
import 'package:todaybread/models/store/store_image_response.dart';
import 'package:todaybread/models/store/store_info_response.dart';
import 'package:todaybread/models/store/store_status_response.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'package:todaybread/services/network/multipart_image_helper.dart';
import 'package:todaybread/services/store/store_api.dart';

/// 가게 도메인 서비스입니다.
class StoreService {
  StoreService._();

  static final StoreService instance = StoreService._();

  final StoreApi _api = StoreApi(DioClient.instance);

  Future<StoreStatusResponse> getStatus() async {
    return await _api.getStatus();
  }

  Future<StoreInfoResponse> getStoreInfo() async {
    return await _api.getStoreInfo();
  }

  Future<List<NearbyStoreResponse>> getNearbyStores({
    required double lat,
    required double lng,
    int radius = 3,
  }) async {
    return await _api.getNearbyStores(lat, lng, radius);
  }

  Future<StoreDetailResponse> getStoreDetail(int storeId) async {
    return await _api.getStoreDetail(storeId);
  }

  Future<List<FavouriteStoreResponse>> getFavouriteStores() async {
    return await _api.getFavouriteStores();
  }

  Future<FavouriteStoreToggleResponse> toggleFavouriteStore(int storeId) async {
    return await _api.toggleFavouriteStore({'storeId': storeId});
  }

  Future<StoreInfoResponse> createStore(
    StoreCommonRequest request,
    List<XFile> images,
  ) async {
    final formData = FormData();
    formData.files.add(
      MapEntry(
        'request',
        MultipartFile.fromString(
          jsonEncode(request.toJson()),
          filename: 'request.json',
          contentType: MediaType('application', 'json'),
        ),
      ),
    );
    for (final image in images) {
      formData.files.add(
        MapEntry('images', await MultipartImageHelper.fromXFile(image)),
      );
    }

    final response = await DioClient.instance.post<Map<String, dynamic>>(
      '/api/boss/store',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return StoreInfoResponse.fromJson(response.data!);
  }

  Future<StoreCommonResponse> updateStore(StoreCommonRequest request) async {
    return await _api.updateStore(request.toJson());
  }

  Future<List<StoreImageResponse>> updateImages(List<XFile> images) async {
    final formData = FormData();
    for (final image in images) {
      formData.files.add(
        MapEntry('images', await MultipartImageHelper.fromXFile(image)),
      );
    }

    final response = await DioClient.instance.put<List<dynamic>>(
      '/api/boss/store/images',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return response.data!
        .map(
          (value) => StoreImageResponse.fromJson(value as Map<String, dynamic>),
        )
        .toList();
  }
}
