import 'dart:io';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/store/favourite_store_response.dart';
import 'package:todaybread/models/store/favourite_store_toggle_response.dart';
import 'package:todaybread/models/store/store_common_request.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_detail_response.dart';
import 'package:todaybread/models/store/store_image_response.dart';
import 'package:todaybread/models/store/store_info_response.dart';
import 'package:todaybread/models/store/store_status_response.dart';
import 'package:todaybread/services/network/dio_client.dart';
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
    final directory = await Directory.systemTemp.createTemp(
      'todaybread_store_',
    );
    final requestFile = File('${directory.path}/request.json');
    await requestFile.writeAsString(jsonEncode(request.toJson()));

    final imageFiles = images.map((image) => File(image.path)).toList();

    try {
      return await _api.createStore(requestFile, imageFiles);
    } finally {
      if (await requestFile.exists()) {
        await requestFile.delete();
      }
      if (await directory.exists()) {
        await directory.delete();
      }
    }
  }

  Future<StoreCommonResponse> updateStore(StoreCommonRequest request) async {
    return await _api.updateStore(request.toJson());
  }

  Future<List<StoreImageResponse>> updateImages(List<XFile> images) async {
    final imageFiles = images.map((image) => File(image.path)).toList();
    return await _api.updateImages(imageFiles);
  }
}
