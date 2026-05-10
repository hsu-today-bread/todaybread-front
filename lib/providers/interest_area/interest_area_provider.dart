import 'package:flutter/material.dart';
import 'package:todaybread/models/interest_area/interest_area_response.dart';
import 'package:todaybread/services/interest_area/interest_area_service.dart';
import 'package:todaybread/services/network/api_exception.dart';

class InterestAreaProvider extends ChangeNotifier {
  final _service = InterestAreaService.instance;

  InterestAreaResponse? interestArea;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> fetch() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      interestArea = await _service.getInterestArea();
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
      if (interestArea == null) {
        interestArea = await _service.createInterestArea(
          name: name,
          address: address,
          latitude: latitude,
          longitude: longitude,
        );
      } else {
        interestArea = await _service.updateInterestArea(
          name: name,
          address: address,
          latitude: latitude,
          longitude: longitude,
        );
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
      final result = await _service.deleteInterestArea();
      interestArea = null;
      return result;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return (success: false, keywordNotificationDisabled: false);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
