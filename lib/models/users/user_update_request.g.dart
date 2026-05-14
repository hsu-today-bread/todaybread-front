// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdateRequest _$UserUpdateRequestFromJson(Map<String, dynamic> json) =>
    UserUpdateRequest(
      nickname: json['nickname'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$UserUpdateRequestToJson(UserUpdateRequest instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
    };
