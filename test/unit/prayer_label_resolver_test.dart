// Guarantees Friday and Ramadan terminology mapping rules.
import 'package:digitalminaret/core/labels/prayer_label_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = PrayerLabelResolver();

  test('Friday + Dhuhr + isRamadan=false => Jumuah', () {
    final friday = DateTime(2026, 3, 6);
    final label = resolver.resolve(
      prayerName: 'Dhuhr',
      date: friday,
      isRamadan: false,
    );
    expect(label, 'Jumuah');
  });

  test('Monday + Dhuhr => Dhuhr', () {
    final monday = DateTime(2026, 3, 2);
    final label = resolver.resolve(
      prayerName: 'Dhuhr',
      date: monday,
      isRamadan: false,
    );
    expect(label, 'Dhuhr');
  });

  test('isRamadan=true + Maghrib => Iftar', () {
    final label = resolver.resolve(
      prayerName: 'Maghrib',
      date: DateTime(2026, 3, 2),
      isRamadan: true,
    );
    expect(label, 'Iftar');
  });

  test('isRamadan=false + Maghrib => Maghrib', () {
    final label = resolver.resolve(
      prayerName: 'Maghrib',
      date: DateTime(2026, 4, 2),
      isRamadan: false,
    );
    expect(label, 'Maghrib');
  });

  test('isRamadan=true + Fajr => Suhoor', () {
    final label = resolver.resolve(
      prayerName: 'Fajr',
      date: DateTime(2026, 3, 2),
      isRamadan: true,
    );
    expect(label, 'Suhoor');
  });

  test('isRamadan=false + Fajr => Fajr', () {
    final label = resolver.resolve(
      prayerName: 'Fajr',
      date: DateTime(2026, 4, 2),
      isRamadan: false,
    );
    expect(label, 'Fajr');
  });

  test('isRamadan=true + Asr keeps default', () {
    final label = resolver.resolve(
      prayerName: 'Asr',
      date: DateTime(2026, 3, 2),
      isRamadan: true,
    );
    expect(label, 'Asr');
  });

  test('unknown prayerName returns original fallback', () {
    final label = resolver.resolve(
      prayerName: 'UnknownPrayer',
      date: DateTime(2026, 3, 2),
      isRamadan: true,
    );
    expect(label, 'UnknownPrayer');
  });
}
