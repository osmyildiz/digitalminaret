import '../../data/models/location_model.dart';
import '../../data/repositories/prayer_repository.dart';

class CalculatePrayerTimesUseCase {
  const CalculatePrayerTimesUseCase(this._repository);

  final PrayerRepository _repository;

  Future<void> call(LocationModel location) {
    return _repository.calculateAndCachePrayerTimes(location);
  }
}
