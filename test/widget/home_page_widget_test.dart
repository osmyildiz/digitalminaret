// Guarantees HomeScreen renders real labels/states with injected deterministic dependencies.
import 'dart:async';

import 'package:digitalminaret/core/labels/prayer_label_resolver.dart';
import 'package:digitalminaret/core/rules/season_rules_service.dart';
import 'package:digitalminaret/core/time/date_time_provider.dart';
import 'package:digitalminaret/core/enums/prayer_type.dart';
import 'package:digitalminaret/data/models/location_model.dart';
import 'package:digitalminaret/data/models/prayer_times_model.dart';
import 'package:digitalminaret/data/services/widget_service.dart';
import 'package:digitalminaret/presentation/providers/location_provider.dart';
import 'package:digitalminaret/presentation/providers/prayer_provider.dart';
import 'package:digitalminaret/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_support/mocks/mocks.dart';

class _FixedDateTimeProvider implements DateTimeProvider {
  const _FixedDateTimeProvider(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

class _FakeSeasonRulesService implements SeasonRulesService {
  const _FakeSeasonRulesService(this.value);

  final bool value;

  @override
  bool isRamadan(DateTime date, {String? cityName}) => value;

  @override
  HijriDate toHijri(DateTime date) =>
      const HijriDate(year: 1447, month: 8, day: 1);

  @override
  String hijriDateText(DateTime date) => '1 Shaaban 1447 AH';

  @override
  String? eidPrayerLabel(DateTime date) => null;
}

class _NoopWidgetService extends WidgetService {
  @override
  Future<void> updateWidget(PrayerTimesModel times, {String locale = 'en'}) async {}
}

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    required DateTime now,
    required bool isRamadan,
  }) async {
    final prayerRepo = MockPrayerRepository();
    final locationRepo = MockLocationRepository();

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
    when(() => prayerRepo.getTimeUntilNextPrayer()).thenAnswer(
      (_) => Stream<Duration>.periodic(
        const Duration(seconds: 1),
        (_) => const Duration(hours: 1),
      ),
    );

    when(() => locationRepo.getCachedLocation()).thenAnswer(
      (_) async => const LocationModel(
        latitude: 42.6526,
        longitude: -73.7562,
        cityName: 'Albany',
        countryCode: 'US',
      ),
    );

    final locationProvider = LocationProvider(locationRepository: locationRepo);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_open_count': 0,
      'has_rated': true,
    });

    final testPrayerProvider = PrayerProvider(
      prayerRepository: prayerRepo,
      widgetService: _NoopWidgetService(),
    );
    await testPrayerProvider.loadPrayerTimes();
    await locationProvider.loadLocation();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PrayerProvider>.value(
            value: testPrayerProvider,
          ),
          ChangeNotifierProvider<LocationProvider>.value(
            value: locationProvider,
          ),
        ],
        child: MaterialApp(
          home: HomeScreen(
            showQiblaCompass: false,
            dateTimeProvider: _FixedDateTimeProvider(now),
            seasonRulesService: _FakeSeasonRulesService(isRamadan),
            prayerLabelResolver: const PrayerLabelResolver(),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets('Friday shows Jumuah instead of Dhuhr', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 3, 6, 13, 0), isRamadan: false);

    expect(find.text('JUMUAH'), findsWidgets);
    expect(find.text('DHUHR'), findsNothing);
  });

  testWidgets('Ramadan mode shows Suhoor and Iftar labels', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 3, 2, 13, 0), isRamadan: true);

    expect(find.text('SUHOOR'), findsWidgets);
    expect(find.text('IFTAR'), findsWidgets);
  });

  testWidgets('Non-Ramadan mode shows Fajr and Maghrib labels', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 4, 2, 13, 0), isRamadan: false);

    expect(find.text('FAJR'), findsWidgets);
    expect(find.text('MAGHRIB'), findsWidgets);
  });

  testWidgets('Home shows location and countdown text', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 4, 2, 13, 0), isRamadan: false);

    expect(find.textContaining('Albany'), findsWidgets);
    expect(find.textContaining('PM'), findsWidgets);
  });

  testWidgets('Home loads with deterministic injected clock', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 4, 2, 20, 0), isRamadan: false);

    expect(find.text('ISHA'), findsWidgets);
  });
}
