// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword_delete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeywordDeleteResponse _$KeywordDeleteResponseFromJson(
        Map<String, dynamic> json) =>
    KeywordDeleteResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$KeywordDeleteResponseToJson(
        KeywordDeleteResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
