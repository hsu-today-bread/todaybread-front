import 'package:flutter/material.dart';
import 'package:todaybread/models/boss/boss_request.dart';
import 'package:todaybread/models/boss/boss_response.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/services/auth/auth_token_storage.dart';
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
    required String businessStartDate,
    required String representativeName,
    required AuthProvider authProvider,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _service.approve(
        BossRequest(
          bossNumber: bossNumber,
          businessStartDate: businessStartDate,
          representativeName: representativeName,
        ),
      );
      lastResponse = response;

      if (response.success) {
        // 사업자 인증 성공 시 백엔드가 BOSS 권한이 반영된 새 토큰을 발급한다.
        // 응답의 새 토큰으로 교체한 뒤 role 기반 UI를 갱신한다.
        if (response.accessToken != null && response.refreshToken != null) {
          await AuthTokenStorage.instance.saveTokens(
            accessToken: response.accessToken!,
            refreshToken: response.refreshToken!,
          );
        }
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
