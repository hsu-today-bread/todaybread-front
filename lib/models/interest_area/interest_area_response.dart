class InterestAreaResponse {
  const InterestAreaResponse({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double radiusKm;

  factory InterestAreaResponse.fromJson(Map<String, dynamic> json) {
    return InterestAreaResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 3,
    );
  }
}

class InterestAreaRequest {
  const InterestAreaRequest({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class InterestAreaDeleteResponse {
  const InterestAreaDeleteResponse({
    required this.success,
    required this.keywordNotificationDisabled,
  });

  final bool success;
  final bool keywordNotificationDisabled;

  factory InterestAreaDeleteResponse.fromJson(Map<String, dynamic> json) {
    return InterestAreaDeleteResponse(
      success: json['success'] as bool? ?? false,
      keywordNotificationDisabled:
          json['keywordNotificationDisabled'] as bool? ?? false,
    );
  }
}
