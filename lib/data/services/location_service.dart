import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

import '../../core/errors/exceptions.dart';
import '../models/location_model.dart';

abstract class GeolocatorGateway {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position> getCurrentPosition();
}

class DefaultGeolocatorGateway implements GeolocatorGateway {
  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<Position> getCurrentPosition() =>
      Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
}

abstract class GeocodingGateway {
  Future<List<geo.Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  );

  Future<List<geo.Location>> locationFromAddress(String address);
}

class DefaultGeocodingGateway implements GeocodingGateway {
  @override
  Future<List<geo.Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) {
    return geo.placemarkFromCoordinates(latitude, longitude);
  }

  @override
  Future<List<geo.Location>> locationFromAddress(String address) {
    return geo.locationFromAddress(address);
  }
}

class LocationService {
  LocationService({
    GeolocatorGateway? geolocatorGateway,
    GeocodingGateway? geocodingGateway,
  }) : _geolocatorGateway = geolocatorGateway ?? DefaultGeolocatorGateway(),
       _geocodingGateway = geocodingGateway ?? DefaultGeocodingGateway();

  final GeolocatorGateway _geolocatorGateway;
  final GeocodingGateway _geocodingGateway;

  Future<LocationModel> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw AppPermissionDeniedException('Location permission was denied.');
    }

    final position = await _geolocatorGateway.getCurrentPosition();
    final cityName = await getCityName(position.latitude, position.longitude);

    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: cityName,
      countryCode: '',
    );
  }

  Future<bool> requestPermission() async {
    final isEnabled = await _geolocatorGateway.isLocationServiceEnabled();
    if (!isEnabled) {
      throw ServiceDisabledException('Location services are disabled.');
    }

    var permission = await _geolocatorGateway.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorGateway.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<String> getCityName(double lat, double lon) async {
    final places = await _geocodingGateway.placemarkFromCoordinates(lat, lon);
    if (places.isEmpty) {
      return 'Unknown';
    }

    final place = places.first;
    if ((place.locality ?? '').isNotEmpty) {
      return place.locality!;
    }

    if ((place.administrativeArea ?? '').isNotEmpty) {
      return place.administrativeArea!;
    }

    return 'Unknown';
  }

  Future<List<LocationModel>> searchByQuery(String query) async {
    if (query.trim().isEmpty) {
      return const <LocationModel>[];
    }

    List<geo.Location> points;
    try {
      points = await _geocodingGateway.locationFromAddress(query);
    } catch (_) {
      throw AppException(
        'Location search needs internet. Check connection and try again.',
      );
    }
    if (points.isEmpty) {
      return const <LocationModel>[];
    }

    final results = <LocationModel>[];
    final seen = <String>{};

    for (final point in points.take(6)) {
      // Reverse-geocode can fail on some emulators/devices. Keep results usable.
      geo.Placemark? mark;
      try {
        final marks = await _geocodingGateway.placemarkFromCoordinates(
          point.latitude,
          point.longitude,
        );
        mark = marks.isNotEmpty ? marks.first : null;
      } catch (_) {
        mark = null;
      }

      final city = (mark?.locality ?? '').isNotEmpty
          ? mark!.locality!
          : ((mark?.administrativeArea ?? '').isNotEmpty
                ? mark!.administrativeArea!
                : query);
      final country = mark?.isoCountryCode ?? '';
      final key = '$city|$country';
      if (seen.contains(key)) {
        continue;
      }
      seen.add(key);
      results.add(
        LocationModel(
          latitude: point.latitude,
          longitude: point.longitude,
          cityName: city,
          countryCode: country,
        ),
      );
    }

    return results;
  }
}
