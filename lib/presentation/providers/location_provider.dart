import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/location_repository.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider({required LocationRepository locationRepository})
    : _locationRepository = locationRepository;

  final LocationRepository _locationRepository;

  LocationModel? _location;
  bool _isLoading = false;
  String? _errorMessage;
  List<LocationModel> _manualCandidates = const <LocationModel>[];

  LocationModel? get location => _location;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LocationModel> get manualCandidates => _manualCandidates;

  Future<void> loadLocation() async {
    _isLoading = true;
    notifyListeners();

    _location = await _locationRepository.getCachedLocation();
    _errorMessage = null;

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> refreshCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      _location = await _locationRepository.getCurrentLocation();
      _errorMessage = null;
      return true;
    } catch (error) {
      if (error is AppException) {
        _errorMessage = error.message;
      } else {
        _errorMessage = 'Unable to get location. Try entering a location.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setManualLocation(LocationModel location) async {
    _isLoading = true;
    notifyListeners();

    _location = await _locationRepository.saveManualLocation(location);
    _errorMessage = null;
    _manualCandidates = const <LocationModel>[];

    _isLoading = false;
    notifyListeners();
  }

  /// Silently checks GPS and updates location if moved >10 km.
  /// Returns true if location was updated, false otherwise.
  /// Times out after 5 seconds to avoid blocking app startup.
  Future<bool> refreshIfMoved({double thresholdKm = 10}) async {
    if (_location == null || _isLoading) {
      return false;
    }
    try {
      final current = await _locationRepository
          .getCurrentLocation()
          .timeout(const Duration(seconds: 5));
      final distance = _location!.distanceKmTo(current);
      if (distance >= thresholdKm) {
        _location = current;
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      // Silently fail - user didn't ask for this, don't show errors
      return false;
    }
  }

  Future<void> searchManualLocations(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _manualCandidates = await _locationRepository.searchLocations(query);
      if (_manualCandidates.isEmpty) {
        _errorMessage = 'No locations found. Try another search.';
      }
    } catch (error) {
      _manualCandidates = const <LocationModel>[];
      if (error is AppException) {
        _errorMessage = error.message;
      } else {
        _errorMessage = 'Location search failed. Try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
