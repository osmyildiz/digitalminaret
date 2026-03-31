// Guarantees DST/timezone/day rollover and non-negative countdown behavior.
import 'package:flutter_test/flutter_test.dart';

DateTime nextPrayer({
  required DateTime now,
  required List<DateTime> today,
  required DateTime tomorrowFajr,
}) {
  for (final prayer in today) {
    if (!prayer.isBefore(now)) {
      return prayer;
    }
  }
  return tomorrowFajr;
}

Duration countdown({required DateTime now, required DateTime target}) {
  final diff = target.difference(now);
  return diff.isNegative ? Duration.zero : diff;
}

void main() {
  test('DST start boundary before/after is monotonic', () {
    final before = DateTime.parse('2026-03-08T01:59:00-05:00');
    final after = DateTime.parse('2026-03-08T03:01:00-04:00');
    expect(after.isAfter(before), isTrue);
  });

  test('DST end boundary repeated hour still monotonic with explicit offset', () {
    final first = DateTime.parse('2026-11-01T01:10:00-04:00');
    final second = DateTime.parse('2026-11-01T01:20:00-05:00');
    expect(second.isAfter(first), isTrue);
  });

  test('same local wall clock in NY and Istanbul represent different instants', () {
    final ny = DateTime.parse('2026-02-15T12:10:00-05:00');
    final ist = DateTime.parse('2026-02-15T12:10:00+03:00');
    expect(ny.isAfter(ist), isTrue);
  });

  test('23:50 next prayer becomes tomorrow fajr', () {
    final now = DateTime(2026, 2, 15, 23, 50);
    final today = <DateTime>[
      DateTime(2026, 2, 15, 5, 32),
      DateTime(2026, 2, 15, 6, 50),
      DateTime(2026, 2, 15, 12, 10),
      DateTime(2026, 2, 15, 15, 46),
      DateTime(2026, 2, 15, 17, 29),
      DateTime(2026, 2, 15, 18, 47),
    ];

    final next = nextPrayer(
      now: now,
      today: today,
      tomorrowFajr: DateTime(2026, 2, 16, 5, 31),
    );

    expect(next, DateTime(2026, 2, 16, 5, 31));
  });

  test('exact-equality with prayer time resolves as current/next now', () {
    final now = DateTime(2026, 2, 15, 17, 29);
    final next = nextPrayer(
      now: now,
      today: <DateTime>[DateTime(2026, 2, 15, 17, 29)],
      tomorrowFajr: DateTime(2026, 2, 16, 5, 31),
    );
    expect(next, DateTime(2026, 2, 15, 17, 29));
  });

  test('countdown clamps negative values to zero', () {
    final now = DateTime(2026, 2, 15, 20, 0);
    final target = DateTime(2026, 2, 15, 19, 0);
    expect(countdown(now: now, target: target), Duration.zero);
  });
}
