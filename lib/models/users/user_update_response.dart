import 'package:json_annotation/json_annotation.dart';

part 'user_update_response.g.dart';

/// 사용자 정보 수정 응답 DTO입니다.
@JsonSerializable()
class UserUpdateResponse {
  final String nickname;
  final String name;
  final String phoneNumber;

  UserUpdateResponse({
    required this.nickname,
    required this.name,
    required this.phoneNumber,
  });

  factory UserUpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateResponseToJson(this);
}
