import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/store/store_common_request.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_image_response.dart';
import 'package:todaybread/models/store/store_info_response.dart';
import 'package:todaybread/models/store/store_status_response.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/store/store_service.dart';

/// 가게 상태와 등록/수정 API 호출을 관리하는 Provider입니다.
class StoreProvider extends ChangeNotifier {
  final StoreService _service = StoreService.instance;

  bool isLoading = false;
  bool hasFetchedStatus = false;
  bool hasRegisteredStore = false;
  String? errorMessage;
  StoreInfoResponse? storeInfo;

  bool get hasStore => hasRegisteredStore;
  StoreCommonResponse? get store => storeInfo?.store;

  Future<StoreStatusResponse?> fetchStatus() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.getStatus();
      hasRegisteredStore = response.hasStore;
      storeInfo = null;
      if (response.hasStore) {
        storeInfo = await _service.getStoreInfo();
      }
      hasFetchedStatus = true;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      hasRegisteredStore = false;
      storeInfo = null;
      hasFetchedStatus = true;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<StoreInfoResponse?> createStore(
    StoreCommonRequest request,
    List<XFile> images,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.createStore(request, images);
      hasRegisteredStore = true;
      storeInfo = response;
      hasFetchedStatus = true;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<StoreCommonResponse?> updateStore(StoreCommonRequest request) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.updateStore(request);
      hasRegisteredStore = true;
      storeInfo =
          (storeInfo ?? StoreInfoResponse(store: response, images: const []))
              .copyWith(store: response);
      hasFetchedStatus = true;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<StoreImageResponse>?> updateImages(List<XFile> images) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.updateImages(images);
      hasRegisteredStore = true;
      if (storeInfo != null) {
        storeInfo = storeInfo!.copyWith(images: response);
      }
      hasFetchedStatus = true;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
