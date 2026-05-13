import 'package:flutter/material.dart';
import 'package:todaybread/models/boss/boss_order_response.dart';
import 'package:todaybread/services/boss/boss_order_service.dart';
import 'package:todaybread/services/network/api_exception.dart';

class BossOrderProvider extends ChangeNotifier {
  final BossOrderService _service = BossOrderService.instance;

  bool isLoading = false;
  bool hasFetched = false;
  String? errorMessage;
  int? processingOrderId;
  List<BossOrderResponse> orders = [];

  Future<List<BossOrderResponse>?> fetchOrders({
    int page = 0,
    int size = 50,
    bool silent = false,
  }) async {
    try {
      if (!silent) {
        isLoading = true;
      }
      errorMessage = null;
      if (!silent) {
        notifyListeners();
      }

      final response = await _service.getOrders(page: page, size: size);
      orders = response.orders;
      hasFetched = true;
      errorMessage = null;
      return response.orders;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      if (!hasFetched) {
        orders = [];
      }
      hasFetched = true;
      return null;
    } finally {
      if (!silent) {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<bool> confirmPickup(int orderId) async {
    try {
      processingOrderId = orderId;
      errorMessage = null;
      notifyListeners();

      await _service.confirmPickup(orderId);
      orders = orders.where((order) => order.id != orderId).toList();
      return true;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return false;
    } finally {
      processingOrderId = null;
      notifyListeners();
    }
  }
}
