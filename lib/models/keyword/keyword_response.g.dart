// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeywordResponse _$KeywordResponseFromJson(Map<String, dynamic> json) =>
    KeywordResponse(
      userKeywordId: (json['userKeywordId'] as num).toInt(),
      displayText: json['displayText'] as String,
    );

Map<String, dynamic> _$KeywordResponseToJson(KeywordResponse instance) =>
    <String, dynamic>{
      'userKeywordId': instance.userKeywordId,
      'displayText': instance.displayText,
    };
