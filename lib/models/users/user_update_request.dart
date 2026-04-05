import 'package:json_annotation/json_annotation.dart';

part 'user_update_request.g.dart';

/// 사용자 정보 수정 요청 DTO입니다.
@JsonSerializable()
class UserUpdateRequest {
  final String nickname;
  final String name;
  final String phoneNumber;

  UserUpdateRequest({
    required this.nickname,
    required this.name,
    required this.phoneNumber,
  });

  factory UserUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserUpdateRequestToJson(this);
}
