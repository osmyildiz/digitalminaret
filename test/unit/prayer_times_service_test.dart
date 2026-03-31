// Guarantees adhan-based prayer times are valid, deterministic and configurable.
import 'package:digitalminaret/core/enums/calculation_method.dart';
import 'package:digitalminaret/core/enums/madhab.dart';
import 'package:digitalminaret/data/services/adhan_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const albanyLat = 42.6526;
  const albanyLng = -73.7562;
  final service = AdhanService();

  test('returns ordered prayer times for Albany with ISNA', () {
    final result = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 2, 15),
      method: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
      locationName: 'Albany',
    );

    expect(result.locationName, 'Albany');
    expect(result.fajr.isBefore(result.sunrise), isTrue);
    expect(result.sunrise.isBefore(result.dhuhr), isTrue);
    expect(result.dhuhr.isBefore(result.asr), isTrue);
    expect(result.asr.isBefore(result.maghrib), isTrue);
    expect(result.maghrib.isBefore(result.isha), isTrue);
  });

  test('same inputs produce deterministic output', () {
    final a = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 2, 15),
      method: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
    );
    final b = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 2, 15),
      method: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
    );

    expect(a.fajr, b.fajr);
    expect(a.sunrise, b.sunrise);
    expect(a.dhuhr, b.dhuhr);
    expect(a.asr, b.asr);
    expect(a.maghrib, b.maghrib);
    expect(a.isha, b.isha);
  });

  test('MWL differs from ISNA at least one key prayer', () {
    final isna = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 2, 15),
      method: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
    );
    final mwl = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 2, 15),
      method: CalculationMethod.muslimWorldLeague,
      madhab: Madhab.nonHanafi,
    );

    expect(isna.fajr != mwl.fajr || isna.isha != mwl.isha, isTrue);
  });

  test('Egyptian differs from Turkey at least one key prayer', () {
    final egypt = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 2, 15),
      method: CalculationMethod.egyptian,
      madhab: Madhab.nonHanafi,
    );
    final turkey = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 2, 15),
      method: CalculationMethod.turkeyDiyanet,
      madhab: Madhab.nonHanafi,
    );

    expect(egypt.fajr != turkey.fajr || egypt.isha != turkey.isha, isTrue);
  });

  test('Hanafi madhab makes Asr later than non-Hanafi', () {
    final nonHanafi = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 6, 1),
      method: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
    );
    final hanafi = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 6, 1),
      method: CalculationMethod.isna,
      madhab: Madhab.hanafi,
    );

    expect(hanafi.asr.isAfter(nonHanafi.asr), isTrue);
  });

  test('high latitude edge case returns valid non-null times', () {
    final result = service.calculatePrayerTimes(
      latitude: 60.1699,
      longitude: 24.9384,
      date: DateTime(2026, 6, 1),
      method: CalculationMethod.muslimWorldLeague,
      madhab: Madhab.nonHanafi,
      locationName: 'Helsinki',
    );

    expect(result.fajr, isNotNull);
    expect(result.sunrise, isNotNull);
    expect(result.isha, isNotNull);
    expect(result.fajr.isBefore(result.isha), isTrue);
  });

  test('different date gives different daily times', () {
    final today = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 2, 15),
      method: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
    );
    final tomorrow = service.calculatePrayerTimes(
      latitude: albanyLat,
      longitude: albanyLng,
      date: DateTime(2026, 2, 16),
      method: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
    );

    expect(today.fajr != tomorrow.fajr || today.maghrib != tomorrow.maghrib, isTrue);
  });
}
