import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/models/store/business_hours_response.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_detail_response.dart';
import 'package:todaybread/models/store/store_image_response.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/store/store_service.dart';
import 'package:todaybread/utils/display_helper.dart';

class StoreDetailProvider extends ChangeNotifier {
  StoreDetailProvider({required this.storeId}) {
    _startClockTimer();
  }

  final int storeId;
  final StoreService _storeService = StoreService.instance;
  Timer? _clockTimer;

  bool isLoading = false;
  bool hasFetched = false;
  bool isTogglingFavourite = false;
  String? errorMessage;
  StoreDetailResponse? storeDetail;
  bool isFavourite = false;
  double? distanceKm;
  int currentImageIndex = 0;

  StoreCommonResponse? get store => storeDetail?.store;
  List<StoreImageResponse> get storeImages => storeDetail?.images ?? const [];
  List<BreadCommonResponse> get breads => storeDetail?.breads ?? const [];
  List<BusinessHoursResponse> get businessHours =>
      store?.businessHours ?? const [];

  String get fullAddress {
    final currentStore = store;
    if (currentStore == null) {
      return '';
    }

    final detail = currentStore.addressLine2.trim();
    if (detail.isEmpty) {
      return currentStore.addressLine1;
    }
    return '${currentStore.addressLine1} $detail';
  }

  String? get todayLastOrderTime {
    final todayDayOfWeek = DateTime.now().weekday;
    for (final value in businessHours) {
      if (value.dayOfWeek == todayDayOfWeek) {
        return value.lastOrderTime;
      }
    }
    return null;
  }

  String get remainingTimeText {
    return DisplayHelper.buildLastOrderRemainingTimeText(
      isSelling: storeDetail?.isSelling ?? false,
      lastOrderTime: todayLastOrderTime,
    );
  }

  String get distanceText => DisplayHelper.formatDistanceKm(distanceKm);

  Future<void> fetch() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      storeDetail = await _storeService.getStoreDetail(storeId);
      currentImageIndex = 0;
      await Future.wait([_loadFavouriteState(), _loadDistance()]);
      hasFetched = true;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      storeDetail = null;
      hasFetched = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> toggleFavourite() async {
    if (isTogglingFavourite) {
      return null;
    }

    try {
      isTogglingFavourite = true;
      notifyListeners();

      final response = await _storeService.toggleFavouriteStore(storeId);
      isFavourite = response.added;
      return null;
    } catch (e) {
      return ApiException.messageFrom(e);
    } finally {
      isTogglingFavourite = false;
      notifyListeners();
    }
  }

  void setCurrentImageIndex(int value) {
    if (currentImageIndex == value) {
      return;
    }
    currentImageIndex = value;
    notifyListeners();
  }

  Future<void> _loadFavouriteState() async {
    try {
      final favourites = await _storeService.getFavouriteStores();
      isFavourite = favourites.any((value) => value.storeId == storeId);
    } catch (_) {
      isFavourite = false;
    }
  }

  Future<void> _loadDistance() async {
    final currentStore = store;
    if (currentStore == null) {
      return;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        distanceKm = null;
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        distanceKm = null;
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        currentStore.latitude,
        currentStore.longitude,
      );
      distanceKm = distanceMeters / 1000;
    } catch (_) {
      distanceKm = null;
    }
  }

  void _startClockTimer() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (storeDetail == null) {
        return;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
