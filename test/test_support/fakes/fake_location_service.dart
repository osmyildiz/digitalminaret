import 'package:digitalminaret/data/models/location_model.dart';

class FakeLocationService {
  FakeLocationService({this.current, this.searchResults = const <LocationModel>[]});

  LocationModel? current;
  List<LocationModel> searchResults;

  Future<LocationModel?> getCurrent() async => current;

  Future<List<LocationModel>> search(String query) async {
    if (query.trim().isEmpty) {
      return const <LocationModel>[];
    }
    return searchResults;
  }
}
