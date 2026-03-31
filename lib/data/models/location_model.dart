import 'dart:math' as math;

class LocationModel {
  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.countryCode,
  });

  final double latitude;
  final double longitude;
  final String cityName;
  final String countryCode;

  /// Haversine formula - returns distance in kilometers.
  double distanceKmTo(LocationModel other) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'countryCode': countryCode,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['cityName'] as String,
      countryCode: json['countryCode'] as String,
    );
  }
}
