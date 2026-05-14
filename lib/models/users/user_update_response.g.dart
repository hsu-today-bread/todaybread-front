// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdateResponse _$UserUpdateResponseFromJson(Map<String, dynamic> json) =>
    UserUpdateResponse(
      nickname: json['nickname'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$UserUpdateResponseToJson(UserUpdateResponse instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
    };
