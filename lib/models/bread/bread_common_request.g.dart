// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bread_common_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreadCommonRequest _$BreadCommonRequestFromJson(Map<String, dynamic> json) =>
    BreadCommonRequest(
      name: json['name'] as String,
      originalPrice: (json['originalPrice'] as num).toInt(),
      salePrice: (json['salePrice'] as num).toInt(),
      remainingQuantity: (json['remainingQuantity'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$BreadCommonRequestToJson(BreadCommonRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'originalPrice': instance.originalPrice,
      'salePrice': instance.salePrice,
      'remainingQuantity': instance.remainingQuantity,
      'description': instance.description,
    };
