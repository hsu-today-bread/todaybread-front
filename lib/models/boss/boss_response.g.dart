// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boss_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BossResponse _$BossResponseFromJson(Map<String, dynamic> json) => BossResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$BossResponseToJson(BossResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'message': instance.message,
    };
