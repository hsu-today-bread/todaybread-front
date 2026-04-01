import 'package:json_annotation/json_annotation.dart';

part 'bread_common_response.g.dart';

/// 빵 공통 응답 DTO입니다.
@JsonSerializable()
class BreadCommonResponse {
  final int id;
  final int storeId;
  final String name;
  final int originalPrice;
  final int salePrice;
  final int remainingQuantity;
  final String description;
  final String? imageUrl;

  BreadCommonResponse({
    required this.id,
    required this.storeId,
    required this.name,
    required this.originalPrice,
    required this.salePrice,
    required this.remainingQuantity,
    required this.description,
    required this.imageUrl,
  });

  factory BreadCommonResponse.fromJson(Map<String, dynamic> json) =>
      _$BreadCommonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BreadCommonResponseToJson(this);
}
