import 'package:json_annotation/json_annotation.dart';

part 'verify_identity_response.g.dart';

@JsonSerializable()
class VerifyIdentityResponse {
  final bool verified;
  final String email;

  VerifyIdentityResponse({required this.verified, required this.email});

  factory VerifyIdentityResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyIdentityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyIdentityResponseToJson(this);
}
