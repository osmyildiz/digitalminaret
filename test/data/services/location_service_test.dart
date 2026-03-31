import 'package:digitalminaret/data/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class FakeGeolocatorGateway implements GeolocatorGateway {
  FakeGeolocatorGateway({
    required this.permission,
    required this.position,
    this.enabled = true,
  });

  final LocationPermission permission;
  final Position position;
  final bool enabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<Position> getCurrentPosition() async => position;

  @override
  Future<bool> isLocationServiceEnabled() async => enabled;

  @override
  Future<LocationPermission> requestPermission() async => permission;
}

class FakeGeocodingGateway implements GeocodingGateway {
  @override
  Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    return [const Placemark(locality: 'Albany', isoCountryCode: 'US')];
  }

  @override
  Future<List<Location>> locationFromAddress(String address) async {
    return <Location>[
      Location(
        latitude: 42.6526,
        longitude: -73.7562,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

void main() {
  test('returns mock coordinates and city', () async {
    final service = LocationService(
      geolocatorGateway: FakeGeolocatorGateway(
        permission: LocationPermission.whileInUse,
        position: Position(
          longitude: -73.7562,
          latitude: 42.6526,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 0,
          altitudeAccuracy: 1,
          heading: 0,
          headingAccuracy: 1,
          speed: 0,
          speedAccuracy: 1,
        ),
      ),
      geocodingGateway: FakeGeocodingGateway(),
    );

    final location = await service.getCurrentLocation();

    expect(location.latitude, 42.6526);
    expect(location.longitude, -73.7562);
    expect(location.cityName, 'Albany');
  });
}
