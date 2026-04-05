import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/store/business_hours_request.dart';
import 'package:todaybread/models/store/store_common_request.dart';
import 'package:todaybread/utils/business_hours_helper.dart';

class BossStoreCreateProvider extends ChangeNotifier {
  BossStoreCreateProvider()
    : templateBusinessHours = const BusinessHoursRequest(
        dayOfWeek: 1,
        isClosed: false,
        startTime: defaultBusinessStartTime,
        endTime: defaultBusinessEndTime,
        lastOrderTime: defaultBusinessLastOrderTime,
      ),
      businessHours = List.generate(
        7,
        (index) => BusinessHoursRequest(
          dayOfWeek: index + 1,
          isClosed: false,
          startTime: defaultBusinessStartTime,
          endTime: defaultBusinessEndTime,
          lastOrderTime: defaultBusinessLastOrderTime,
        ),
      );

  int currentStep = 0;
  String? errorMessage;

  String addressLine1 = '';
  String addressLine2 = '';
  String name = '';
  String phone = '';
  String description = '';
  String latitude = '';
  String longitude = '';
  final List<XFile> imageFiles = [];
  BusinessHoursRequest templateBusinessHours;
  List<BusinessHoursRequest> businessHours;

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

  void updateTemplateBusinessHours(BusinessHoursRequest value) {
    templateBusinessHours = value;
    _syncAfterChange();
  }

  void updateBusinessHours(BusinessHoursRequest value) {
    businessHours =
        businessHours
            .map((hours) => hours.dayOfWeek == value.dayOfWeek ? value : hours)
            .toList()
          ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    _syncAfterChange();
  }

  void applyTemplateToAll() {
    _applyTemplate(const [1, 2, 3, 4, 5, 6, 7]);
  }

  void applyTemplateToWeekdays() {
    _applyTemplate(const [1, 2, 3, 4, 5]);
  }

  void applyTemplateToWeekend() {
    _applyTemplate(const [6, 7]);
  }

  String? replaceImages(List<XFile> files) {
    if (files.length > 5) {
      return '매장 이미지는 최대 5장까지 선택할 수 있습니다.';
    }
    imageFiles
      ..clear()
      ..addAll(files.take(5));
    _syncAfterChange();
    return null;
  }

  String? addImage(XFile file) {
    if (imageFiles.length >= 5) {
      return '매장 이미지는 최대 5장까지 선택할 수 있습니다.';
    }
    imageFiles.add(file);
    _syncAfterChange();
    return null;
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= imageFiles.length) {
      return;
    }
    imageFiles.removeAt(index);
    _syncAfterChange();
  }

  bool nextStep() {
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
      businessHours: businessHours,
    );
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
        if (imageFiles.isEmpty) {
          return '매장 이미지를 1장 이상 선택해주세요.';
        }
        return null;
      case 4:
        for (final value in businessHours) {
          final error = validateBusinessHoursValues(
            isClosed: value.isClosed,
            startTime: value.startTime,
            endTime: value.endTime,
            lastOrderTime: value.lastOrderTime,
            label: '${weekdayLabel(value.dayOfWeek)}요일',
          );
          if (error != null) {
            return error;
          }
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

  void _applyTemplate(List<int> targetDays) {
    businessHours = businessHours.map((value) {
      if (!targetDays.contains(value.dayOfWeek)) {
        return value;
      }
      return value.copyWith(
        isClosed: templateBusinessHours.isClosed,
        startTime: templateBusinessHours.isClosed
            ? null
            : templateBusinessHours.startTime,
        endTime: templateBusinessHours.isClosed
            ? null
            : templateBusinessHours.endTime,
        lastOrderTime: templateBusinessHours.isClosed
            ? null
            : templateBusinessHours.lastOrderTime,
      );
    }).toList()..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    _syncAfterChange();
  }

  void _syncAfterChange() {
    errorMessage = null;
    notifyListeners();
  }
}
