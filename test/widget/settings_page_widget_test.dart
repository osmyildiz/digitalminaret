// Guarantees real SettingsScreen behavior with injected fakes and deterministic providers.
import 'dart:async';

import 'package:digitalminaret/core/enums/calculation_method.dart';
import 'package:digitalminaret/core/enums/prayer_type.dart';
import 'package:digitalminaret/data/models/prayer_times_model.dart';
import 'package:digitalminaret/data/repositories/settings_repository.dart';
import 'package:digitalminaret/data/services/adhan_pack_download_service.dart';
import 'package:digitalminaret/data/services/widget_service.dart';
import 'package:digitalminaret/core/constants/adhan_packs.dart';
import 'package:digitalminaret/data/services/storage_service.dart';
import 'package:digitalminaret/presentation/providers/location_provider.dart';
import 'package:digitalminaret/presentation/providers/prayer_provider.dart';
import 'package:digitalminaret/presentation/providers/settings_provider.dart';
import 'package:digitalminaret/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_support/mocks/mocks.dart';

class _FakePackGateway implements AdhanPackDownloadGateway {
  @override
  Future<void> downloadPack(AdhanPack pack) async {}

  @override
  Future<bool> isPackDownloaded(String packId) async => false;

  @override
  Future<String?> localPathFor({
    required String packId,
    required PrayerType prayerType,
  }) async => null;
}

class _NoopWidgetService extends WidgetService {
  @override
  Future<void> updateWidget(PrayerTimesModel times, {String locale = 'en'}) async {}
}

void main() {
  Future<({SettingsProvider settingsProvider, int Function() scheduledCount})>
  pumpSettings(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final settingsProvider = SettingsProvider(
      settingsRepository: SettingsRepository(storageService: StorageService()),
    );
    await settingsProvider.loadSettings();

    final prayerRepo = MockPrayerRepository();
    final locationRepo = MockLocationRepository();

    final now = DateTime(2026, 4, 2, 13, 0);
    final times = PrayerTimesModel(
      fajr: DateTime(now.year, now.month, now.day, 5, 31),
      sunrise: DateTime(now.year, now.month, now.day, 6, 49),
      dhuhr: DateTime(now.year, now.month, now.day, 12, 10),
      asr: DateTime(now.year, now.month, now.day, 15, 47),
      maghrib: DateTime(now.year, now.month, now.day, 17, 30),
      isha: DateTime(now.year, now.month, now.day, 18, 48),
      date: DateTime(now.year, now.month, now.day),
      locationName: 'Albany',
    );

    when(() => prayerRepo.getTodayPrayerTimes()).thenAnswer((_) async => times);
    when(() => prayerRepo.getCurrentOrNextPrayer()).thenReturn(PrayerType.isha);
    when(
      () => prayerRepo.getTimeUntilNextPrayer(),
    ).thenAnswer((_) => const Stream<Duration>.empty());

    when(() => locationRepo.getCachedLocation()).thenAnswer((_) async => null);

    final prayerProvider = PrayerProvider(
      prayerRepository: prayerRepo,
      widgetService: _NoopWidgetService(),
    );
    final locationProvider = LocationProvider(locationRepository: locationRepo);
    await prayerProvider.loadPrayerTimes();

    var scheduleCount = 0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
          ChangeNotifierProvider<PrayerProvider>.value(value: prayerProvider),
          ChangeNotifierProvider<LocationProvider>.value(value: locationProvider),
        ],
        child: MaterialApp(
          home: SettingsScreen(
            runBootTasks: false,
            adhanPackDownloadService: _FakePackGateway(),
            scheduleNotifications: (times, settings) async {
              scheduleCount += 1;
            },
            initializeNotifications: () async {},
            requestNotificationPermission: () async => true,
            urlLauncher: (uri) async => true,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    return (settingsProvider: settingsProvider, scheduledCount: () => scheduleCount);
  }

  testWidgets('real settings renders Non-Hanafi and Hanafi labels without overflow', (
    tester,
  ) async {
    await pumpSettings(tester);

    expect(find.text('Non-Hanafi'), findsOneWidget);
    expect(find.text('Hanafi'), findsOneWidget);
  });

  testWidgets('real settings tap Hanafi updates provider madhab', (tester) async {
    final result = await pumpSettings(tester);

    await tester.tap(find.text('Hanafi'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(result.settingsProvider.settings.madhab.name, 'hanafi');
  });

  testWidgets('real settings changing method dropdown updates provider', (tester) async {
    final result = await pumpSettings(tester);

    await tester.tap(find.text('North America (ISNA)').first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Egyptian').last);
    await tester.pump(const Duration(milliseconds: 300));

    expect(result.settingsProvider.settings.calculationMethod, CalculationMethod.egyptian);
  });

  testWidgets('real settings notification switch off triggers schedule sync', (tester) async {
    final result = await pumpSettings(tester);

    final switches = find.byType(Switch);
    expect(switches, findsAtLeastNWidgets(1));

    await tester.tap(switches.first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(result.settingsProvider.settings.notificationsEnabled, isFalse);
    expect(result.scheduledCount(), greaterThanOrEqualTo(1));
  });

  testWidgets('real settings notification switch on asks permission path and keeps true', (
    tester,
  ) async {
    final result = await pumpSettings(tester);

    final switches = find.byType(Switch);
    await tester.tap(switches.first); // off
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byType(Switch).first); // on
    await tester.pump(const Duration(milliseconds: 300));

    expect(result.settingsProvider.settings.notificationsEnabled, isTrue);
  });
}
