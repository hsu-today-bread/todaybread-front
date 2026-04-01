// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bread_common_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreadCommonResponse _$BreadCommonResponseFromJson(Map<String, dynamic> json) =>
    BreadCommonResponse(
      id: (json['id'] as num).toInt(),
      storeId: (json['storeId'] as num).toInt(),
      name: json['name'] as String,
      originalPrice: (json['originalPrice'] as num).toInt(),
      salePrice: (json['salePrice'] as num).toInt(),
      remainingQuantity: (json['remainingQuantity'] as num).toInt(),
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$BreadCommonResponseToJson(
  BreadCommonResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'storeId': instance.storeId,
  'name': instance.name,
  'originalPrice': instance.originalPrice,
  'salePrice': instance.salePrice,
  'remainingQuantity': instance.remainingQuantity,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
};
