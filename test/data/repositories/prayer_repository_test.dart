import 'package:digitalminaret/core/enums/calculation_method.dart';
import 'package:digitalminaret/core/enums/madhab.dart';
import 'package:digitalminaret/core/enums/prayer_alert_mode.dart';
import 'package:digitalminaret/core/enums/prayer_type.dart';
import 'package:digitalminaret/data/models/location_model.dart';
import 'package:digitalminaret/data/models/prayer_times_model.dart';
import 'package:digitalminaret/data/models/settings_model.dart';
import 'package:digitalminaret/data/repositories/prayer_repository.dart';
import 'package:digitalminaret/data/services/adhan_service.dart';
import 'package:digitalminaret/data/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;
  late PrayerRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    repository = PrayerRepository(
      storageService: storage,
      adhanService: AdhanService(),
    );
  });

  test('calculates and caches Albany prayer times using ISNA', () async {
    const location = LocationModel(
      latitude: 42.6526,
      longitude: -73.7562,
      cityName: 'Albany',
      countryCode: 'US',
    );

    await storage.saveLocation(location);
    await storage.saveSettings(
      const SettingsModel(
        calculationMethod: CalculationMethod.isna,
        madhab: Madhab.nonHanafi,
        selectedAdhanPackId: 'tr_istanbul',
        notificationsEnabled: true,
        adhanSoundEnabled: true,
        postAdhanDuaEnabled: true,
        enabledPrayers: {
          PrayerType.fajr: true,
          PrayerType.sunrise: false,
          PrayerType.dhuhr: true,
          PrayerType.asr: true,
          PrayerType.maghrib: true,
          PrayerType.isha: true,
        },
        prayerAlertModes: {
          PrayerType.fajr: PrayerAlertMode.sound,
          PrayerType.sunrise: PrayerAlertMode.off,
          PrayerType.dhuhr: PrayerAlertMode.sound,
          PrayerType.asr: PrayerAlertMode.sound,
          PrayerType.maghrib: PrayerAlertMode.sound,
          PrayerType.isha: PrayerAlertMode.sound,
        },
      ),
    );

    await repository.calculateAndCachePrayerTimes(location);
    final times = await repository.getTodayPrayerTimes();

    expect(times.locationName, 'Albany');
    expect(times.fajr.isBefore(times.dhuhr), isTrue);
    expect(times.maghrib.isBefore(times.isha), isTrue);
  });

  test('returns next prayer type', () async {
    final now = DateTime.now();
    const location = LocationModel(
      latitude: 42.6526,
      longitude: -73.7562,
      cityName: 'Albany',
      countryCode: 'US',
    );
    final model = PrayerTimesModel(
      fajr: now.subtract(const Duration(hours: 5)),
      sunrise: now.subtract(const Duration(hours: 4)),
      dhuhr: now.add(const Duration(minutes: 10)),
      asr: now.add(const Duration(hours: 3)),
      maghrib: now.add(const Duration(hours: 6)),
      isha: now.add(const Duration(hours: 8)),
      date: DateTime(now.year, now.month, now.day),
      locationName: 'Albany',
      latitude: location.latitude,
      longitude: location.longitude,
      calculationMethodName: CalculationMethod.isna.name,
      madhabName: Madhab.nonHanafi.name,
    );

    await storage.saveLocation(location);
    await storage.savePrayerTimes(model);
    await repository.getTodayPrayerTimes();

    expect(repository.getCurrentOrNextPrayer(), PrayerType.dhuhr);
  });

  test('model serialization works', () {
    final model = PrayerTimesModel(
      fajr: DateTime.utc(2026, 2, 15, 10),
      sunrise: DateTime.utc(2026, 2, 15, 11),
      dhuhr: DateTime.utc(2026, 2, 15, 17),
      asr: DateTime.utc(2026, 2, 15, 20),
      maghrib: DateTime.utc(2026, 2, 15, 23),
      isha: DateTime.utc(2026, 2, 16, 0),
      date: DateTime.utc(2026, 2, 15),
      locationName: 'Albany',
    );

    final encoded = model.toJson();
    final decoded = PrayerTimesModel.fromJson(encoded);

    expect(decoded.locationName, 'Albany');
    expect(decoded.fajr.toIso8601String(), model.fajr.toIso8601String());
  });
}
