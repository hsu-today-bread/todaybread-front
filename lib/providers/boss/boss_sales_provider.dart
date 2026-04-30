import 'package:flutter/material.dart';
import 'package:todaybread/models/boss/boss_parsing.dart';
import 'package:todaybread/models/boss/boss_sales_response.dart';
import 'package:todaybread/services/boss/boss_sales_service.dart';
import 'package:todaybread/services/network/api_exception.dart';

class BossSalesProvider extends ChangeNotifier {
  final BossSalesService _service = BossSalesService.instance;

  bool isMonthlyLoading = false;
  bool isDailyLoading = false;
  bool hasFetchedMonthly = false;
  String? errorMessage;
  DateTime? loadingDailyDate;

  final Map<String, BossMonthlySalesResponse> _monthlyCache = {};
  final Map<String, BossDailySalesResponse> _dailyCache = {};

  BossMonthlySalesResponse? monthlySalesFor(DateTime month) {
    return _monthlyCache[bossMonthKey(month)];
  }

  BossDailySalesResponse? dailySalesFor(DateTime date) {
    return _dailyCache[bossDateKey(date)];
  }

  int amountForDate(DateTime date) {
    final normalized = bossNormalizeDate(date);
    final monthly = monthlySalesFor(normalized);
    if (monthly != null && monthly.hasDailyBreakdown) {
      return monthly.amountFor(normalized);
    }
    return dailySalesFor(normalized)?.totalAmount ?? 0;
  }

  bool hasSalesOn(DateTime date) {
    final normalized = bossNormalizeDate(date);
    final monthly = monthlySalesFor(normalized);
    if (monthly != null && monthly.hasDailyBreakdown) {
      return monthly.hasSalesOn(normalized);
    }
    final daily = dailySalesFor(normalized);
    if (daily != null) {
      return daily.totalAmount > 0;
    }
    return false;
  }

  Future<BossMonthlySalesResponse?> fetchMonthlySales(
    DateTime month, {
    bool forceRefresh = false,
  }) async {
    final key = bossMonthKey(month);
    if (!forceRefresh && _monthlyCache.containsKey(key)) {
      hasFetchedMonthly = true;
      return _monthlyCache[key];
    }

    try {
      isMonthlyLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.getMonthlySales(month);
      _monthlyCache[key] = response;
      hasFetchedMonthly = true;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      hasFetchedMonthly = true;
      return null;
    } finally {
      isMonthlyLoading = false;
      notifyListeners();
    }
  }

  Future<BossDailySalesResponse?> fetchDailySales(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final normalized = bossNormalizeDate(date);
    final key = bossDateKey(normalized);
    if (!forceRefresh && _dailyCache.containsKey(key)) {
      return _dailyCache[key];
    }

    try {
      isDailyLoading = true;
      loadingDailyDate = normalized;
      errorMessage = null;
      notifyListeners();

      final response = await _service.getDailySales(normalized);
      _dailyCache[key] = response;
      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return null;
    } finally {
      isDailyLoading = false;
      loadingDailyDate = null;
      notifyListeners();
    }
  }
}
