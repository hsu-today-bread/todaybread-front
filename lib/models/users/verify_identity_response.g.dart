// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_identity_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyIdentityResponse _$VerifyIdentityResponseFromJson(
        Map<String, dynamic> json) =>
    VerifyIdentityResponse(
      verified: json['verified'] as bool,
      email: json['email'] as String,
    );

Map<String, dynamic> _$VerifyIdentityResponseToJson(
        VerifyIdentityResponse instance) =>
    <String, dynamic>{
      'verified': instance.verified,
      'email': instance.email,
    };
