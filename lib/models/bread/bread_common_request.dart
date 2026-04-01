import 'package:json_annotation/json_annotation.dart';

part 'bread_common_request.g.dart';

/// 가게 등록/수정 공통 요청 DTO입니다.
@JsonSerializable()
class BreadCommonRequest {
  final String name;
  final int originalPrice;
  final int salePrice;
  final int remainingQuantity;
  final String description;

  BreadCommonRequest({
    required this.name,
    required this.originalPrice,
    required this.salePrice,
    required this.remainingQuantity,
    required this.description,
  });

  factory BreadCommonRequest.fromJson(Map<String, dynamic> json) =>
      _$BreadCommonRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BreadCommonRequestToJson(this);
}
