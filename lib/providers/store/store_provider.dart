import 'package:flutter/material.dart';
import 'package:todaybread/models/store/store_common_request.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_status_response.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/store/store_service.dart';

/// 가게 상태와 등록/수정 API 호출을 관리하는 Provider입니다.
class StoreProvider extends ChangeNotifier {
  final StoreService _service = StoreService.instance;

  bool isLoading = false;
  bool hasFetchedStatus = false;
  String? errorMessage;
  StoreCommonResponse? store;

  bool get hasStore => store != null;

  Future<StoreStatusResponse?> fetchStatus() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.getStatus();
      store = response.storeCommonResponse;
      hasFetchedStatus = true;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      hasFetchedStatus = true;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<StoreCommonResponse?> createStore(StoreCommonRequest request) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.createStore(request);
      store = response;
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
      store = response;
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
