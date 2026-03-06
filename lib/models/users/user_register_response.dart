import 'package:json_annotation/json_annotation.dart';

part 'user_register_response.g.dart';

@JsonSerializable()
class UserRegisterResponse {
  final bool status;
  final String message;

  UserRegisterResponse({
    required this.status,
    required this.message,
  });

  factory UserRegisterResponse.fromJson(Map<String, dynamic> json)
  => _$UserRegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserRegisterResponseToJson(this);
}