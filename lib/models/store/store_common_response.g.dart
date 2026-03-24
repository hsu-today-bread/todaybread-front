// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_common_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreCommonResponse _$StoreCommonResponseFromJson(Map<String, dynamic> json) =>
    StoreCommonResponse(
      name: json['name'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      endTime: json['endTime'] as String,
      lastOrderTime: json['lastOrderTime'] as String,
      orderTime: json['orderTime'] as String,
    );

Map<String, dynamic> _$StoreCommonResponseToJson(
        StoreCommonResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'description': instance.description,
      'addressLine1': instance.addressLine1,
      'addressLine2': instance.addressLine2,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'endTime': instance.endTime,
      'lastOrderTime': instance.lastOrderTime,
      'orderTime': instance.orderTime,
    };
