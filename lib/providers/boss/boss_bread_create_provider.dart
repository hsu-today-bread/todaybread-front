import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/bread/bread_common_request.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';

/// 메뉴 등록 화면에서만 쓰는 step 전용 provider입니다.
///
/// 사용자가 입력 중인 draft 데이터를 보관하고,
/// 각 단계 이동 전 검증까지 담당합니다.
class BossBreadCreateProvider extends ChangeNotifier {
  BossBreadCreateProvider({
    BreadCommonResponse? initialBread,
    int initialStep = 0,
  }) {
    currentStep = initialStep.clamp(0, 3);
    if (initialBread == null) {
      return;
    }

    name = initialBread.name;
    originalPrice = initialBread.originalPrice.toString();
    salePrice = initialBread.salePrice.toString();
    quantity = initialBread.remainingQuantity;
    description = initialBread.description;
    initialImageUrl = initialBread.imageUrl;
  }

  int currentStep = 0;
  String? errorMessage;

  String name = '';
  String originalPrice = '';
  String salePrice = '';
  int quantity = 1;
  XFile? imageFile;
  String? initialImageUrl;
  String description = '';

  bool get isLastStep => currentStep == 3;

  bool validateCurrentStep() {
    final error = _validateCurrentStep();
    if (error != null) {
      errorMessage = error;
      notifyListeners();
      return false;
    }
    errorMessage = null;
    notifyListeners();
    return true;
  }

  void updateName(String value) {
    name = value;
    _sync();
  }

  void updateOriginalPrice(String value) {
    originalPrice = value;
    _sync();
  }

  void updateSalePrice(String value) {
    salePrice = value;
    _sync();
  }

  void incrementQuantity() {
    quantity += 1;
    _sync();
  }

  void decrementQuantity() {
    if (quantity <= 1) {
      return;
    }
    quantity -= 1;
    _sync();
  }

  void updateImage(XFile value) {
    imageFile = value;
    _sync();
  }

  void clearImage() {
    imageFile = null;
    _sync();
  }

  void updateDescription(String value) {
    description = value;
    _sync();
  }

  bool nextStep() {
    if (!validateCurrentStep()) {
      return false;
    }
    if (!isLastStep) {
      currentStep += 1;
      notifyListeners();
    }
    return true;
  }

  void previousStep() {
    if (currentStep == 0) {
      return;
    }
    currentStep -= 1;
    errorMessage = null;
    notifyListeners();
  }

  BreadCommonRequest buildRequest() {
    final parsedOriginalPrice = int.tryParse(originalPrice);
    final parsedSalePrice = int.tryParse(salePrice);
    if (parsedOriginalPrice == null || parsedSalePrice == null) {
      throw const FormatException('가격 정보가 올바르지 않습니다.');
    }

    return BreadCommonRequest(
      name: name.trim(),
      originalPrice: parsedOriginalPrice,
      salePrice: parsedSalePrice,
      remainingQuantity: quantity,
      description: description.trim(),
    );
  }

  String? _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        if (name.trim().isEmpty) {
          return '메뉴명을 입력해주세요.';
        }
        return null;
      case 1:
        if (originalPrice.trim().isEmpty || salePrice.trim().isEmpty) {
          return '원가와 할인가를 모두 입력해주세요.';
        }
        final parsedOriginalPrice = int.tryParse(originalPrice);
        final parsedSalePrice = int.tryParse(salePrice);
        if (parsedOriginalPrice == null || parsedSalePrice == null) {
          return '가격은 숫자로 입력해주세요.';
        }
        if (parsedOriginalPrice <= 0 || parsedSalePrice <= 0) {
          return '가격은 0보다 크게 입력해주세요.';
        }
        if (parsedSalePrice > parsedOriginalPrice) {
          return '할인가는 원가보다 클 수 없습니다.';
        }
        return null;
      case 2:
        if (imageFile == null &&
            (initialImageUrl == null || initialImageUrl!.isEmpty)) {
          return '상품 사진을 등록해주세요.';
        }
        return null;
      case 3:
        if (description.trim().isEmpty) {
          return '메뉴 설명을 입력해주세요.';
        }
        if (description.trim().length > 255) {
          return '메뉴 설명은 255자 이내로 입력해주세요.';
        }
        return null;
      default:
        return null;
    }
  }

  void _sync() {
    errorMessage = null;
    notifyListeners();
  }
}
