import 'package:adhan/adhan.dart' as adhan;
import 'package:digitalminaret/core/enums/calculation_method.dart';
import 'package:digitalminaret/core/enums/madhab.dart';
import 'package:digitalminaret/data/services/adhan_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phase1 package imports are available', () {
    final service = AdhanService();
    final times = service.calculatePrayerTimes(
      latitude: 40.7128,
      longitude: -74.0060,
      date: DateTime.utc(2026, 2, 15),
      method: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
    );

    expect(times.fajr, isA<DateTime>());
    expect(adhan.Coordinates(40.0, -74.0).latitude, 40.0);
  });
}
