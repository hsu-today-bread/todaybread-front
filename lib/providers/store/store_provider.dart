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
      // 사장님 탭 진입 시 서버 기준으로 "매장 있음/없음" 상태를 확정한다.
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
      // 등록 성공 후에는 별도 재조회 없이 현재 매장 정보를 바로 화면에 반영한다.
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
