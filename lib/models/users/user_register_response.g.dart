// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_register_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRegisterResponse _$UserRegisterResponseFromJson(
        Map<String, dynamic> json) =>
    UserRegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$UserRegisterResponseToJson(
        UserRegisterResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
