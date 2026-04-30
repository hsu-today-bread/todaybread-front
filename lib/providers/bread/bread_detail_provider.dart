import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todaybread/models/bread/bread_detail_response.dart';
import 'package:todaybread/models/store/business_hours_response.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_detail_response.dart';
import 'package:todaybread/models/store/store_image_response.dart';
import 'package:todaybread/services/bread/bread_service.dart';
import 'package:todaybread/services/cart/cart_service.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/store/store_service.dart';

class BreadDetailProvider extends ChangeNotifier {
  BreadDetailProvider({required this.breadId, required this.storeId}) {
    _startClockTimer();
  }

  final int breadId;
  final int storeId;
  final BreadService _breadService = BreadService.instance;
  final StoreService _storeService = StoreService.instance;
  final CartService _cartService = CartService.instance;
  Timer? _clockTimer;

  bool isLoading = false;
  bool hasFetched = false;
  bool isAddingToCart = false;
  String? errorMessage;
  BreadDetailResponse? breadDetail;
  StoreDetailResponse? storeDetail;
  int quantity = 1;

  StoreCommonResponse? get store => storeDetail?.store;
  List<StoreImageResponse> get storeImages => storeDetail?.images ?? const [];
  List<BusinessHoursResponse> get businessHours =>
      store?.businessHours ?? const [];

  bool get canOrder {
    final bread = breadDetail;
    if (bread == null) {
      return false;
    }
    return bread.isSelling && bread.remainingQuantity > 0;
  }

  int get maxQuantity => breadDetail?.remainingQuantity ?? 0;

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

  Future<void> fetch() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final results = await (
        _breadService.getBreadDetail(breadId),
        _storeService.getStoreDetail(storeId),
      ).wait;

      breadDetail = results.$1;
      storeDetail = results.$2;
      quantity = maxQuantity > 0 ? 1 : 0;
      hasFetched = true;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      breadDetail = null;
      storeDetail = null;
      quantity = 1;
      hasFetched = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _startClockTimer() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (breadDetail == null || storeDetail == null) {
        return;
      }
      notifyListeners();
    });
  }

  /// 장바구니에 현재 수량만큼 빵을 추가합니다.
  /// 성공 시 true, 실패 시 errorMessage를 세팅하고 false 반환.
  Future<bool> addToCart() async {
    final bread = breadDetail;
    if (bread == null || isAddingToCart) return false;

    isAddingToCart = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _cartService.addItem(bread.id, quantity);
      return true;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return false;
    } finally {
      isAddingToCart = false;
      notifyListeners();
    }
  }

  void decreaseQuantity() {
    if (maxQuantity <= 0) {
      return;
    }
    if (quantity > 1) {
      quantity -= 1;
      notifyListeners();
    }
  }

  void increaseQuantity() {
    if (maxQuantity <= 0) {
      return;
    }
    if (quantity < maxQuantity) {
      quantity += 1;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
