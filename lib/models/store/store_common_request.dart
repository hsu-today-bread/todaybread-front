import 'package:json_annotation/json_annotation.dart';

part 'store_common_request.g.dart';

/// 가게 등록/수정 공통 요청 DTO입니다.
@JsonSerializable()
class StoreCommonRequest {
  final String name;
  final String phone;
  final String description;
  final String addressLine1;
  final String addressLine2;
  final double latitude;
  final double longitude;
  final String endTime;
  final String lastOrderTime;
  final String orderTime;

  StoreCommonRequest({
    required this.name,
    required this.phone,
    required this.description,
    required this.addressLine1,
    required this.addressLine2,
    required this.latitude,
    required this.longitude,
    required this.endTime,
    required this.lastOrderTime,
    required this.orderTime,
  });

  factory StoreCommonRequest.fromJson(Map<String, dynamic> json) =>
      _$StoreCommonRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StoreCommonRequestToJson(this);
}
