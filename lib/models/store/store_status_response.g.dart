// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreStatusResponse _$StoreStatusResponseFromJson(Map<String, dynamic> json) =>
    StoreStatusResponse(
      hasStore: json['hasStore'] as bool,
      storeCommonResponse: json['storeCommonResponse'] == null
          ? null
          : StoreCommonResponse.fromJson(
              json['storeCommonResponse'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoreStatusResponseToJson(
        StoreStatusResponse instance) =>
    <String, dynamic>{
      'hasStore': instance.hasStore,
      'storeCommonResponse': instance.storeCommonResponse,
    };
