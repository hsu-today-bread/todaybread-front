import 'package:todaybread/models/store/business_hours_response.dart';

/// 가게 공통 응답 DTO입니다.
class StoreCommonResponse {
  final int id;
  final String name;
  final String phone;
  final String description;
  final String addressLine1;
  final String addressLine2;
  final double latitude;
  final double longitude;
  final List<BusinessHoursResponse> businessHours;

  StoreCommonResponse({
    required this.id,
    required this.name,
    required this.phone,
    required this.description,
    required this.addressLine1,
    required this.addressLine2,
    required this.latitude,
    required this.longitude,
    required this.businessHours,
  });

  factory StoreCommonResponse.fromJson(Map<String, dynamic> json) {
    return StoreCommonResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      businessHours:
          (json['businessHours'] as List<dynamic>? ?? [])
              .map(
                (value) => BusinessHoursResponse.fromJson(
                  value as Map<String, dynamic>,
                ),
              )
              .toList()
            ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
