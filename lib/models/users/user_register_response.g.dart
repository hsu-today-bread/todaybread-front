// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_register_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRegisterResponse _$UserRegisterResponseFromJson(
        Map<String, dynamic> json) =>
    UserRegisterResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$UserRegisterResponseToJson(
        UserRegisterResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
    };
