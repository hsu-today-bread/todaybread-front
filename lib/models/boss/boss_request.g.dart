// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boss_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BossRequest _$BossRequestFromJson(Map<String, dynamic> json) => BossRequest(
      bossNumber: json['bossNumber'] as String,
      businessStartDate: json['businessStartDate'] as String,
      representativeName: json['representativeName'] as String,
    );

Map<String, dynamic> _$BossRequestToJson(BossRequest instance) =>
    <String, dynamic>{
      'bossNumber': instance.bossNumber,
      'businessStartDate': instance.businessStartDate,
      'representativeName': instance.representativeName,
    };
