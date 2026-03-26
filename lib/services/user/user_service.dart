import 'package:todaybread/models/users/user_update_request.dart';
import 'package:todaybread/models/users/user_update_response.dart';
import 'package:todaybread/services/local/user_local_store.dart';
import 'package:todaybread/services/network/dio_client.dart';

import 'user_api.dart';

/// 사용자 정보 도메인 서비스입니다.
class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final UserApi _api = UserApi(DioClient.instance);

  /// 사용자 프로필을 수정하고 응답 기준으로 로컬 저장소를 동기화합니다.
  Future<UserUpdateResponse> updateProfile(UserUpdateRequest request) async {
    final response = await _api.updateProfile(request);
    await _saveProfileToLocal(response);
    return response;
  }

  Future<void> _saveProfileToLocal(UserUpdateResponse response) async {
    await UserLocalStore.saveUser(
      nickname: response.nickname,
      name: response.name,
      phone: response.phone,
    );
  }
}
