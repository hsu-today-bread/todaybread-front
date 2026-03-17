import 'package:json_annotation/json_annotation.dart';

part 'user_login_response.g.dart';

/// 로그인 응답 DTO
///
/// 서버의 로그인 성공 여부와 JWT 토큰을 담아 전달합니다.
@JsonSerializable()
class UserLoginResponse {
  /// 로그인 성공 여부
  final bool success;

  /// 인증이 필요한 API 호출에 사용하는 access token
  final String? accessToken;

  /// access token 만료 시 재발급에 사용하는 refresh token
  final String? refreshToken;

  /// 로그인 응답 모델을 생성
  UserLoginResponse({
    required this.success,
    this.accessToken,
    this.refreshToken,
  });

  /// JSON 맵을 [UserLoginResponse]로 변환합니다.
  factory UserLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$UserLoginResponseFromJson(json);

  /// 현재 객체를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() => _$UserLoginResponseToJson(this);
}
