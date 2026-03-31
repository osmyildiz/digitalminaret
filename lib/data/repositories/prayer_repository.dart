import '../../core/errors/exceptions.dart';
import '../../core/utils/date_utils.dart';
import '../../core/enums/prayer_type.dart';
import '../models/location_model.dart';
import '../models/prayer_times_model.dart';
import '../models/settings_model.dart';
import '../services/adhan_service.dart';
import '../services/storage_service.dart';

class PrayerRepository {
  PrayerRepository({
    required StorageService storageService,
    required AdhanService adhanService,
  }) : _storageService = storageService,
       _adhanService = adhanService;

  final StorageService _storageService;
  final AdhanService _adhanService;

  PrayerTimesModel? _latestPrayerTimes;

  Future<PrayerTimesModel> getTodayPrayerTimes() async {
    final now = DateTime.now();
    final cached = await _storageService.getPrayerTimes();
    final location = await _storageService.getLocation();
    final settings = await _storageService.getSettings();
    if (location == null) {
      throw DataNotFoundException('Location not found');
    }
    if (cached != null &&
        DateUtilsX.isSameDay(cached.date, now) &&
        _isCacheCompatible(
          cached: cached,
          location: location,
          settings: settings,
        )) {
      _latestPrayerTimes = cached;
      return cached;
    }

    await calculateAndCachePrayerTimes(location);
    return _latestPrayerTimes!;
  }

  bool _isCacheCompatible({
    required PrayerTimesModel cached,
    required LocationModel location,
    required SettingsModel settings,
  }) {
    const tolerance = 0.0001;
    final latOk =
        cached.latitude != null &&
        (cached.latitude! - location.latitude).abs() < tolerance;
    final lonOk =
        cached.longitude != null &&
        (cached.longitude! - location.longitude).abs() < tolerance;
    final methodOk =
        cached.calculationMethodName == settings.calculationMethod.name;
    final madhabOk = cached.madhabName == settings.madhab.name;

    return latOk && lonOk && methodOk && madhabOk;
  }

  Future<void> calculateAndCachePrayerTimes(LocationModel location) async {
    final settings = await _storageService.getSettings();
    final times = _adhanService.calculatePrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      date: DateTime.now(),
      method: settings.calculationMethod,
      madhab: settings.madhab,
      locationName: location.cityName,
    );

    _latestPrayerTimes = times;
    await _storageService.savePrayerTimes(times);
  }

  Stream<Duration> getTimeUntilNextPrayer() {
    return Stream<Duration>.periodic(
      const Duration(seconds: 1),
      (_) => _calculateTimeUntilNextPrayer(DateTime.now()),
    );
  }

  PrayerType? getCurrentOrNextPrayer() {
    final times = _latestPrayerTimes;
    if (times == null) {
      return null;
    }

    return _nextPrayerType(DateTime.now(), times);
  }

  Duration _calculateTimeUntilNextPrayer(DateTime now) {
    final times = _latestPrayerTimes;
    if (times == null) {
      return Duration.zero;
    }

    final nextPrayer = _nextPrayerTime(now, times);
    if (nextPrayer == null) {
      return Duration.zero;
    }

    return nextPrayer.difference(now);
  }

  DateTime? _nextPrayerTime(DateTime now, PrayerTimesModel times) {
    final schedule = <DateTime>[
      times.fajr,
      times.sunrise,
      times.dhuhr,
      times.asr,
      times.maghrib,
      times.isha,
    ];

    for (final time in schedule) {
      if (time.isAfter(now)) {
        return time;
      }
    }
    return null;
  }

  PrayerType? _nextPrayerType(DateTime now, PrayerTimesModel times) {
    final schedule = <PrayerType, DateTime>{
      PrayerType.fajr: times.fajr,
      PrayerType.sunrise: times.sunrise,
      PrayerType.dhuhr: times.dhuhr,
      PrayerType.asr: times.asr,
      PrayerType.maghrib: times.maghrib,
      PrayerType.isha: times.isha,
    };

    for (final entry in schedule.entries) {
      if (entry.value.isAfter(now)) {
        return entry.key;
      }
    }
    return null;
  }
}
