import '../models/location_model.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class LocationRepository {
  LocationRepository({
    required LocationService locationService,
    required StorageService storageService,
  }) : _locationService = locationService,
       _storageService = storageService;

  final LocationService _locationService;
  final StorageService _storageService;

  Future<LocationModel> getCurrentLocation() async {
    final location = await _locationService.getCurrentLocation();
    await _storageService.saveLocation(location);
    return location;
  }

  Future<LocationModel?> getCachedLocation() {
    return _storageService.getLocation();
  }

  Future<LocationModel> saveManualLocation(LocationModel location) async {
    await _storageService.saveLocation(location);
    return location;
  }

  Future<List<LocationModel>> searchLocations(String query) {
    return _locationService.searchByQuery(query);
  }
}
