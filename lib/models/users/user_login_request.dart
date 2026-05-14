import 'package:json_annotation/json_annotation.dart';

part 'user_login_request.g.dart';

/// 로그인 요청 DTO
///
/// 이메일과 비밀번호를 서버로 전달할 때 사용합니다.
@JsonSerializable()
class UserLoginRequest {
  /// 사용자 이메일(로그인 아이디)
  final String email;

  /// 로그인 비밀번호
  final String password;

  UserLoginRequest({
    required this.email,
    required this.password,
  });

  /// JSON 맵을 [UserLoginRequest]로 변환합니다.
  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestFromJson(json);

  /// 현재 객체를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() => _$UserLoginRequestToJson(this);
}
