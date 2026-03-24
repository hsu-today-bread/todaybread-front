import 'package:flutter/material.dart';
import 'package:todaybread/models/store/store_common_request.dart';

class BossStoreCreateProvider extends ChangeNotifier {
  // 매장 등록은 여러 step을 한 화면에서 처리하므로
  // 현재 step index와 입력 중인 draft 값을 이 provider에 모아둔다.
  int currentStep = 0;
  String? errorMessage;

  String addressLine1 = '';
  String addressLine2 = '';
  String name = '';
  String phone = '';
  String description = '';
  String latitude = '';
  String longitude = '';
  String? logoAssetPath;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TimeOfDay? lastOrderTime;

  bool get isLastStep => currentStep == 5;

  void updateAddressLine1(String value) {
    addressLine1 = value;
    _syncAfterChange();
  }

  void updateAddressLine2(String value) {
    addressLine2 = value;
    _syncAfterChange();
  }

  void updateName(String value) {
    name = value;
    _syncAfterChange();
  }

  void updatePhone(String value) {
    phone = value;
    _syncAfterChange();
  }

  void updateDescription(String value) {
    description = value;
    _syncAfterChange();
  }

  void updateLatitude(String value) {
    latitude = value;
    _syncAfterChange();
  }

  void updateLongitude(String value) {
    longitude = value;
    _syncAfterChange();
  }

  void selectLogo(String assetPath) {
    logoAssetPath = assetPath;
    _syncAfterChange();
  }

  void updateStartTime(TimeOfDay value) {
    startTime = value;
    _syncAfterChange();
  }

  void updateEndTime(TimeOfDay value) {
    endTime = value;
    _syncAfterChange();
  }

  void updateLastOrderTime(TimeOfDay value) {
    lastOrderTime = value;
    _syncAfterChange();
  }

  bool nextStep() {
    // step 이동 전에 현재 단계 입력값만 검증한다.
    // 최종 서버 전송 검증은 buildRequest/createStore 시점에서 한 번 더 걸린다.
    final error = _validateCurrentStep();
    if (error != null) {
      errorMessage = error;
      notifyListeners();
      return false;
    }

    if (!isLastStep) {
      currentStep += 1;
      errorMessage = null;
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

  StoreCommonRequest buildRequest() {
    final parsedLatitude = double.tryParse(latitude);
    final parsedLongitude = double.tryParse(longitude);

    if (parsedLatitude == null || parsedLongitude == null) {
      // 백엔드 StoreCommonRequest는 BigDecimal 위도/경도를 필수로 받는다.
      // 지금은 임시 입력값을 받아 double로 보내고, 값이 없으면 예외로 막는다.
      throw const FormatException('위도/경도 정보가 없습니다.');
    }

    return StoreCommonRequest(
      name: name.trim(),
      phone: phone.trim(),
      description: description.trim(),
      addressLine1: addressLine1.trim(),
      addressLine2: addressLine2.trim(),
      latitude: parsedLatitude,
      longitude: parsedLongitude,
      endTime: formatTime(endTime),
      lastOrderTime: formatTime(lastOrderTime),
      orderTime: buildOrderTime(),
    );
  }

  String buildOrderTime() {
    // 백엔드 orderTime은 문자열이므로, 화면에서 고른 시작/종료 시각을
    // 단순 표시 문자열 형태로 묶어서 보낸다.
    final start = formatTime(startTime);
    final end = formatTime(endTime);
    if (start.isEmpty || end.isEmpty) {
      return '';
    }
    return '$start - $end';
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) {
      return '';
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String? _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        if (addressLine1.trim().isEmpty) {
          return '매장 위치를 입력해주세요.';
        }
        if (addressLine2.trim().isEmpty) {
          return '상세 주소를 입력해주세요.';
        }
        if (latitude.trim().isEmpty || longitude.trim().isEmpty) {
          return '위도와 경도를 입력해주세요.';
        }
        if (double.tryParse(latitude) == null ||
            double.tryParse(longitude) == null) {
          return '위도와 경도는 숫자로 입력해주세요.';
        }
        return null;
      case 1:
        if (name.trim().isEmpty) {
          return '매장 이름을 입력해주세요.';
        }
        return null;
      case 2:
        if (phone.trim().isEmpty) {
          return '매장 전화번호를 입력해주세요.';
        }
        return null;
      case 3:
        if (logoAssetPath == null || logoAssetPath!.isEmpty) {
          return '매장 로고를 선택해주세요.';
        }
        return null;
      case 4:
        if (startTime == null) {
          return '가게 시작 시간을 선택해주세요.';
        }
        if (endTime == null) {
          return '가게 종료 시간을 선택해주세요.';
        }
        if (lastOrderTime == null) {
          return '라스트 오더 시간을 선택해주세요.';
        }
        return null;
      case 5:
        if (description.trim().isEmpty) {
          return '매장 소개 글을 입력해주세요.';
        }
        if (description.length > 255) {
          return '매장 소개 글은 255자 이내로 입력해주세요.';
        }
        return null;
      default:
        return null;
    }
  }

  void _syncAfterChange() {
    // 입력이 바뀌는 즉시 화면이 다시 그려져야 로고/시간 선택 결과가 바로 보인다.
    errorMessage = null;
    notifyListeners();
  }
}
