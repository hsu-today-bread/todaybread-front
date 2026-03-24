import 'package:flutter/material.dart';
import 'package:todaybread/models/boss/boss_request.dart';
import 'package:todaybread/models/boss/boss_response.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/boss/boss_service.dart';

/// 사업자 인증 화면 상태를 관리하는 Provider입니다.
class BossProvider extends ChangeNotifier {
  final BossService _service = BossService.instance;

  bool isLoading = false;
  String? errorMessage;
  BossResponse? lastResponse;

  Future<BossResponse?> approveBoss({
    required String bossNumber,
    required AuthProvider authProvider,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.approve(
        BossRequest(bossNumber: bossNumber),
      );
      lastResponse = response;

      if (response.success) {
        await authProvider.refreshRoleFromStoredToken();
      }

      return response;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
