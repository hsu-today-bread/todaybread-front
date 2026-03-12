import 'package:json_annotation/json_annotation.dart';

part 'user_register_request.g.dart';

/// 회원가입 요청 DTO
///
/// 서버에 전달되는 회원가입 입력값을 JSON 형태로 직렬화합니다.
@JsonSerializable()
class UserRegisterRequest {
  /// 사용자 이메일(로그인 아이디)
  final String email;

  /// 사용할 닉네임
  final String nickname;

  /// 사용자 이름
  final String name;

  /// 비밀번호
  final String password;

  /// 전화번호
  final String phone;

  /// 회원가입 요청 모델을 생성합니다.
  UserRegisterRequest({
    required this.email,
    required this.nickname,
    required this.name,
    required this.password,
    required this.phone,
  });

  /// JSON 맵을 [UserRegisterRequest]로 변환합니다.
  factory UserRegisterRequest.fromJson(Map<String, dynamic> json)
  => _$UserRegisterRequestFromJson(json);

  /// 현재 객체를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() => _$UserRegisterRequestToJson(this);
}
