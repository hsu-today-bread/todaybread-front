import 'package:json_annotation/json_annotation.dart';

part 'store_common_response.g.dart';

/// 가게 공통 응답 DTO입니다.
@JsonSerializable()
class StoreCommonResponse {
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

  StoreCommonResponse({
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

  factory StoreCommonResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreCommonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoreCommonResponseToJson(this);
}
