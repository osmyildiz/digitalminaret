// Guarantees Ramadan and Eid seasonal rules are computed from Hijri calendar conversion.
import 'package:digitalminaret/core/rules/season_rules_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = DefaultSeasonRulesService();

  test('converts known Shaaban date near 2026-02-16', () {
    final hijri = service.toHijri(DateTime(2026, 2, 16));

    expect(hijri.month, 8);
    expect(hijri.day, inInclusiveRange(27, 30));
  });

  test('detects Ramadan around 2026-02-20', () {
    expect(service.isRamadan(DateTime(2026, 2, 20)), isTrue);
  });

  test('non-Ramadan date returns false', () {
    expect(service.isRamadan(DateTime(2026, 1, 20)), isFalse);
  });

  test('hijri date text contains month and AH suffix', () {
    final text = service.hijriDateText(DateTime(2026, 2, 16));

    expect(text, contains('AH'));
    expect(text, isNotEmpty);
  });

  test('finds both Eid labels within a Gregorian year', () {
    final labels = <String>{};
    final start = DateTime(2026, 1, 1);
    for (var i = 0; i < 366; i++) {
      final label = service.eidPrayerLabel(start.add(Duration(days: i)));
      if (label != null) {
        labels.add(label);
      }
    }

    expect(labels, contains('Eid al-Fitr Prayer'));
    expect(labels, contains('Eid al-Adha Prayer'));
  });
}
