import '../../data/models/location_model.dart';
import '../../data/repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  const GetCurrentLocationUseCase(this._repository);

  final LocationRepository _repository;

  Future<LocationModel> call() {
    return _repository.getCurrentLocation();
  }
}
