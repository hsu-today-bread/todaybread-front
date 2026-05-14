import 'package:todaybread/models/boss/boss_request.dart';
import 'package:todaybread/models/boss/boss_response.dart';
import 'package:todaybread/services/auth/auth_token_storage.dart';

import '../network/dio_client.dart';
import 'boss_api.dart';

/// 사업자 인증 도메인 서비스입니다.
class BossService {
  BossService._();

  static final BossService instance = BossService._();

  final BossApi _api = BossApi(DioClient.instance);
  final AuthTokenStorage _tokenStorage = AuthTokenStorage.instance;

  /// 사업자 인증을 요청하고, 새 토큰이 오면 저장합니다.
  Future<BossResponse> approve(BossRequest request) async {
    final response = await _api.approve(request);
    if (response.accessToken != null && response.refreshToken != null) {
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
      );
    }
    return response;
  }
}
