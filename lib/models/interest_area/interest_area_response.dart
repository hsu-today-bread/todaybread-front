class InterestAreaResponse {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double radiusKm;

  const InterestAreaResponse({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  factory InterestAreaResponse.fromJson(Map<String, dynamic> json) {
    return InterestAreaResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusKm: (json['radiusKm'] as num).toDouble(),
    );
  }
}
