import 'package:todaybread/models/store/business_hours_request.dart';

/// 가게 등록/수정 공통 요청 DTO입니다.
class StoreCommonRequest {
  final String name;
  final String phone;
  final String description;
  final String addressLine1;
  final String addressLine2;
  final double latitude;
  final double longitude;
  final List<BusinessHoursRequest> businessHours;

  StoreCommonRequest({
    required this.name,
    required this.phone,
    required this.description,
    required this.addressLine1,
    required this.addressLine2,
    required this.latitude,
    required this.longitude,
    required this.businessHours,
  });

  factory StoreCommonRequest.fromJson(Map<String, dynamic> json) {
    return StoreCommonRequest(
      name: json['name'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      businessHours: (json['businessHours'] as List<dynamic>? ?? [])
          .map(
            (value) =>
                BusinessHoursRequest.fromJson(value as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'description': description,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'latitude': latitude,
      'longitude': longitude,
      'businessHours': businessHours.map((value) => value.toJson()).toList(),
    };
  }
}
