import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/bread/bread_common_request.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/services/bread/bread_service.dart';
import 'package:todaybread/services/network/api_exception.dart';

/// 메뉴 도메인 전역 상태를 관리하는 provider입니다.
///
/// 목록 조회와 등록 요청을 service에 위임하고,
/// 화면에는 로딩/에러/목록 상태만 노출합니다.
class BreadProvider extends ChangeNotifier {
  final BreadService _service = BreadService.instance;

  bool isLoading = false;
  bool hasFetched = false;
  String? errorMessage;
  List<BreadCommonResponse> breads = [];

  bool get hasBread => breads.isNotEmpty;

  Future<List<BreadCommonResponse>?> fetchMyBreads() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.getMyBreads();
      breads = response;
      hasFetched = true;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      breads = [];
      hasFetched = true;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<BreadCommonResponse?> createBread(
    BreadCommonRequest request,
    XFile? image,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.createBread(request, image);
      breads = [...breads, response];
      hasFetched = true;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBreadStock({
    required int breadId,
    required int remainingQuantity,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _service.updateBreadStock(
        breadId: breadId,
        remainingQuantity: remainingQuantity,
      );

      breads = breads
          .map(
            (bread) => bread.id == breadId
                ? bread.copyWith(remainingQuantity: remainingQuantity)
                : bread,
          )
          .toList();
      return true;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
