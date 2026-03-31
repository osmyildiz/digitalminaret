import 'package:digitalminaret/core/enums/calculation_method.dart';
import 'package:digitalminaret/core/enums/madhab.dart';
import 'package:digitalminaret/data/services/adhan_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates ordered prayer times for NYC', () {
    final service = AdhanService();

    final result = service.calculatePrayerTimes(
      latitude: 40.7128,
      longitude: -74.0060,
      date: DateTime.utc(2026, 2, 15),
      method: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
      locationName: 'New York',
    );

    expect(result.locationName, 'New York');
    expect(result.fajr.isBefore(result.sunrise), isTrue);
    expect(result.sunrise.isBefore(result.dhuhr), isTrue);
    expect(result.dhuhr.isBefore(result.asr), isTrue);
    expect(result.asr.isBefore(result.maghrib), isTrue);
    expect(result.maghrib.isBefore(result.isha), isTrue);
  });
}
