import 'package:json_annotation/json_annotation.dart';

part 'user_register_request.g.dart';

@JsonSerializable()
class UserRegisterRequest {
  final String email;
  final String nickName;
  final String password;
  final String phoneNumber;

  UserRegisterRequest({
    required this.email,
    required this.nickName,
    required this.password,
    required this.phoneNumber,
  });

  factory UserRegisterRequest.fromJson(Map<String, dynamic> json)
  => _$UserRegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserRegisterRequestToJson(this);
}