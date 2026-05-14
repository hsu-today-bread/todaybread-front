import 'package:flutter/material.dart';
import 'package:todaybread/models/interest_area/interest_area_response.dart';
import 'package:todaybread/services/interest_area/interest_area_service.dart';
import 'package:todaybread/services/network/api_exception.dart';

class InterestAreaProvider extends ChangeNotifier {
  final _service = InterestAreaService.instance;

  InterestAreaResponse? interestArea;
  bool isLoading = false;
  bool isSubmitting = false;
  bool hasFetched = false;
  String? errorMessage;

  Future<void> fetch() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      interestArea = await _service.getInterestArea();
      hasFetched = true;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = InterestAreaRequest(
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
      if (!hasFetched) {
        interestArea = await _service.getInterestArea();
        hasFetched = true;
      }
      if (interestArea == null) {
        interestArea = await _service.createInterestArea(request);
      } else {
        interestArea = await _service.updateInterestArea(request);
      }
      return true;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<({bool success, bool keywordNotificationDisabled})> delete() async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.deleteInterestArea();
      interestArea = null;
      hasFetched = true;
      return (
        success: response.success,
        keywordNotificationDisabled: response.keywordNotificationDisabled,
      );
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return (success: false, keywordNotificationDisabled: false);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
