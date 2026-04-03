import 'package:json_annotation/json_annotation.dart';

part 'user_register_response.g.dart';

/// 회원가입 응답 DTO
///
/// 회원가입 성공 여부와 안내 메시지를 담습니다.
@JsonSerializable()
class UserRegisterResponse {
  /// 회원가입 성공 여부
  final bool success;

  /// 사용자 안내 메시지
  final String message;

  /// 회원가입 응답 모델을 생성합니다.
  UserRegisterResponse({required this.success, required this.message});

  /// JSON 맵을 [UserRegisterResponse]로 변환합니다.
  factory UserRegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$UserRegisterResponseFromJson(json);

  /// 현재 객체를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() => _$UserRegisterResponseToJson(this);
}
