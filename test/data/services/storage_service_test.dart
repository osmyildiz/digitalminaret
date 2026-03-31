import 'package:digitalminaret/core/enums/calculation_method.dart';
import 'package:digitalminaret/core/enums/madhab.dart';
import 'package:digitalminaret/core/enums/prayer_alert_mode.dart';
import 'package:digitalminaret/core/enums/prayer_type.dart';
import 'package:digitalminaret/data/models/location_model.dart';
import 'package:digitalminaret/data/models/prayer_times_model.dart';
import 'package:digitalminaret/data/models/settings_model.dart';
import 'package:digitalminaret/data/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
  });

  test('save and read location', () async {
    const location = LocationModel(
      latitude: 42.6526,
      longitude: -73.7562,
      cityName: 'Albany',
      countryCode: 'US',
    );

    await storage.saveLocation(location);
    final saved = await storage.getLocation();

    expect(saved, isNotNull);
    expect(saved!.cityName, 'Albany');
    expect(saved.latitude, 42.6526);
  });

  test('save and read settings', () async {
    const settings = SettingsModel(
      calculationMethod: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
      selectedAdhanPackId: 'tr_istanbul',
      notificationsEnabled: true,
      adhanSoundEnabled: false,
      postAdhanDuaEnabled: true,
      enabledPrayers: {PrayerType.fajr: true, PrayerType.sunrise: false},
      prayerAlertModes: {
        PrayerType.fajr: PrayerAlertMode.sound,
        PrayerType.sunrise: PrayerAlertMode.off,
      },
    );

    await storage.saveSettings(settings);
    final saved = await storage.getSettings();

    expect(saved.calculationMethod, CalculationMethod.isna);
    expect(saved.adhanSoundEnabled, isFalse);
    expect(saved.enabledPrayers[PrayerType.fajr], isTrue);
  });

  test('save and read prayer times', () async {
    final times = PrayerTimesModel(
      fajr: DateTime.utc(2026, 2, 15, 10),
      sunrise: DateTime.utc(2026, 2, 15, 11),
      dhuhr: DateTime.utc(2026, 2, 15, 17),
      asr: DateTime.utc(2026, 2, 15, 20),
      maghrib: DateTime.utc(2026, 2, 15, 23),
      isha: DateTime.utc(2026, 2, 16, 0),
      date: DateTime.utc(2026, 2, 15),
      locationName: 'Albany',
    );

    await storage.savePrayerTimes(times);
    final saved = await storage.getPrayerTimes();

    expect(saved, isNotNull);
    expect(saved!.locationName, 'Albany');
    expect(saved.dhuhr.toUtc().hour, 17);
  });
}
