import 'package:json_annotation/json_annotation.dart';

part 'user_find_email_response.g.dart';

@JsonSerializable()
class UserFindEmailResponse {
  final String maskedEmail;

  UserFindEmailResponse({required this.maskedEmail});

  factory UserFindEmailResponse.fromJson(Map<String, dynamic> json) =>
      _$UserFindEmailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserFindEmailResponseToJson(this);
}
