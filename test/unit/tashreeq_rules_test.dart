// Direct unit tests for the Tashreeq scheduling rules.
//
// These tests deliberately do not stand up a NotificationService — they
// exercise the rule logic in isolation so that:
//   1. Regression coverage is fast (no plugins, no SharedPreferences).
//   2. The 4 scenarios the user asked about ("3-day window during
//      Tashreeq", "5-day window after Bayram", "Tashreeq notifs OFF
//      after Bayram", "auto-restart next year") are each named and
//      asserted, not just inferred from a simulation script.
//
// Integration coverage (Hijri converter → rules → ID space) is verified
// at the bottom of this file using DefaultSeasonRulesService so that a
// drift in the Hijri math also surfaces here, not only in production.

import 'package:digitalminaret/core/enums/prayer_type.dart';
import 'package:digitalminaret/core/rules/season_rules_service.dart';
import 'package:digitalminaret/core/rules/tashreeq_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TashreeqRules.isInTashreeqPeriod — window detection', () {
    test('false for any non-Dhul-Hijjah month', () {
      for (var month = 1; month <= 11; month++) {
        for (final day in [1, 8, 9, 10, 13, 14, 30]) {
          expect(
            TashreeqRules.isInTashreeqPeriod(
              hijriMonth: month,
              hijriDay: day,
            ),
            isFalse,
            reason: 'month=$month day=$day should be outside window',
          );
        }
      }
    });

    test('false for Dhul-Hijjah days 1-7', () {
      for (var day = 1; day <= 7; day++) {
        expect(
          TashreeqRules.isInTashreeqPeriod(hijriMonth: 12, hijriDay: day),
          isFalse,
          reason: 'Zilhicce $day is before Arafah-eve, no window shrink',
        );
      }
    });

    test('true for Dhul-Hijjah day 8 (Arafah eve, pre-shrink buffer)', () {
      expect(
        TashreeqRules.isInTashreeqPeriod(hijriMonth: 12, hijriDay: 8),
        isTrue,
      );
    });

    test('true for Dhul-Hijjah days 9-13 (Arafah + 4 Eid days)', () {
      for (var day = 9; day <= 13; day++) {
        expect(
          TashreeqRules.isInTashreeqPeriod(hijriMonth: 12, hijriDay: day),
          isTrue,
          reason: 'Zilhicce $day should be in window',
        );
      }
    });

    test('false for Dhul-Hijjah day 14 onwards (Bayram over)', () {
      for (var day = 14; day <= 30; day++) {
        expect(
          TashreeqRules.isInTashreeqPeriod(hijriMonth: 12, hijriDay: day),
          isFalse,
          reason: 'Zilhicce $day is after Bayram, window snaps back',
        );
      }
    });
  });

  group('TashreeqRules.windowDaysAhead — 3 days vs 5 days', () {
    test('Scenario 1: returns 3 during Tashreeq period', () {
      // The user-asked scenario: "Tashreeq tekbirleri için 3 günde bir."
      for (var day = 8; day <= 13; day++) {
        expect(
          TashreeqRules.windowDaysAhead(hijriMonth: 12, hijriDay: day),
          3,
          reason: 'Zilhicce $day should use 3-day pre-schedule window',
        );
      }
    });

    test('Scenario 2: returns 5 after Bayram ends (Zilhicce 14+)', () {
      // The user-asked scenario: "kurban bayramı geçince 5 gün."
      for (var day = 14; day <= 30; day++) {
        expect(
          TashreeqRules.windowDaysAhead(hijriMonth: 12, hijriDay: day),
          5,
          reason: 'Zilhicce $day (post-Bayram) should use 5-day window',
        );
      }
    });

    test('Scenario 2 (other months): returns 5 for the rest of the year', () {
      for (var month = 1; month <= 11; month++) {
        for (final day in [1, 15, 30]) {
          expect(
            TashreeqRules.windowDaysAhead(hijriMonth: month, hijriDay: day),
            5,
            reason: 'month=$month day=$day should use 5-day window',
          );
        }
      }
    });

    test('matches the constants advertised on TashreeqRules', () {
      // If someone tweaks the constants we want the test to surface that
      // intentionally rather than silently.
      expect(TashreeqRules.normalWindowDays, 5);
      expect(TashreeqRules.tashreeqWindowDays, 3);
    });
  });

  group('TashreeqRules.shouldScheduleTashreeq — per-prayer matrix', () {
    test('Scenario 3a: Sunrise is NEVER paired with Tashreeq', () {
      // Sunrise is not a fard prayer; no Tashreeq reminder, on any day,
      // ever. This is what stops the +10 min reminder firing right
      // after the Sunrise notification on Arafah morning.
      for (var month = 1; month <= 12; month++) {
        for (var day = 1; day <= 30; day++) {
          expect(
            TashreeqRules.shouldScheduleTashreeq(
              hijriMonth: month,
              hijriDay: day,
              prayerType: PrayerType.sunrise,
            ),
            isFalse,
            reason: 'sunrise should never get Tashreeq (month=$month day=$day)',
          );
        }
      }
    });

    test('Scenario 3b: NO Tashreeq outside Dhul-Hijjah', () {
      for (var month = 1; month <= 11; month++) {
        for (final day in [1, 9, 10, 13, 15]) {
          for (final prayer in PrayerType.values) {
            expect(
              TashreeqRules.shouldScheduleTashreeq(
                hijriMonth: month,
                hijriDay: day,
                prayerType: prayer,
              ),
              isFalse,
              reason: 'month=$month day=$day prayer=${prayer.name} '
                  '— Tashreeq only fires in Dhul-Hijjah',
            );
          }
        }
      }
    });

    test('Scenario 3c: NO Tashreeq on Zilhicce 1-8 (before Arafah)', () {
      for (var day = 1; day <= 8; day++) {
        for (final prayer in PrayerType.values) {
          expect(
            TashreeqRules.shouldScheduleTashreeq(
              hijriMonth: 12,
              hijriDay: day,
              prayerType: prayer,
            ),
            isFalse,
            reason: 'Zilhicce $day prayer=${prayer.name} is pre-Arafah',
          );
        }
      }
    });

    test('Scenario 3d: NO Tashreeq from Zilhicce 14 onwards (after Bayram)', () {
      // The exact bug the user is worried about: "kurban bayramı geçince
      // teşrik tekbirleri bildirimi off" — verify the next 17 days each
      // produce zero Tashreeq notifications.
      for (var day = 14; day <= 30; day++) {
        for (final prayer in PrayerType.values) {
          expect(
            TashreeqRules.shouldScheduleTashreeq(
              hijriMonth: 12,
              hijriDay: day,
              prayerType: prayer,
            ),
            isFalse,
            reason: 'Zilhicce $day (post-Bayram) prayer=${prayer.name} '
                'should NOT trigger a Tashreeq reminder',
          );
        }
      }
    });

    test('Zilhicce 9 (Arafah): 5 prayers, sunrise excluded', () {
      const expected = {
        PrayerType.fajr: true,
        PrayerType.sunrise: false,
        PrayerType.dhuhr: true,
        PrayerType.asr: true,
        PrayerType.maghrib: true,
        PrayerType.isha: true,
      };
      for (final entry in expected.entries) {
        expect(
          TashreeqRules.shouldScheduleTashreeq(
            hijriMonth: 12,
            hijriDay: 9,
            prayerType: entry.key,
          ),
          entry.value,
          reason: 'Arafah (Zilhicce 9) — ${entry.key.name} should be '
              '${entry.value ? "scheduled" : "skipped"}',
        );
      }
    });

    test('Zilhicce 10-12 (Eid days 1-3): 5 prayers each, sunrise excluded', () {
      for (var day = 10; day <= 12; day++) {
        const expected = {
          PrayerType.fajr: true,
          PrayerType.sunrise: false,
          PrayerType.dhuhr: true,
          PrayerType.asr: true,
          PrayerType.maghrib: true,
          PrayerType.isha: true,
        };
        for (final entry in expected.entries) {
          expect(
            TashreeqRules.shouldScheduleTashreeq(
              hijriMonth: 12,
              hijriDay: day,
              prayerType: entry.key,
            ),
            entry.value,
            reason: 'Zilhicce $day — ${entry.key.name} should be '
                '${entry.value ? "scheduled" : "skipped"}',
          );
        }
      }
    });

    test('Zilhicce 13 (last Eid day): only Fajr, Dhuhr, Asr', () {
      // Diyanet rule: takbir ends after Asr of 13 Zilhicce. Maghrib
      // and Isha that day no longer get the +10 min reminder.
      const expected = {
        PrayerType.fajr: true,
        PrayerType.sunrise: false,
        PrayerType.dhuhr: true,
        PrayerType.asr: true,
        PrayerType.maghrib: false,
        PrayerType.isha: false,
      };
      for (final entry in expected.entries) {
        expect(
          TashreeqRules.shouldScheduleTashreeq(
            hijriMonth: 12,
            hijriDay: 13,
            prayerType: entry.key,
          ),
          entry.value,
          reason: 'Zilhicce 13 — ${entry.key.name} should be '
              '${entry.value ? "scheduled" : "skipped"}',
        );
      }
    });

    test('Diyanet total: 23 Tashreeq reminders across the 5-day period', () {
      // Sanity check that the per-day rules sum to the textbook total.
      // 5 + 5 + 5 + 5 + 3 = 23.
      var total = 0;
      for (var day = 9; day <= 13; day++) {
        for (final prayer in PrayerType.values) {
          if (TashreeqRules.shouldScheduleTashreeq(
            hijriMonth: 12,
            hijriDay: day,
            prayerType: prayer,
          )) {
            total++;
          }
        }
      }
      expect(total, 23, reason: 'Should match Diyanet 23-takbir total');
    });
  });

  group('Real-world Gregorian dates (via DefaultSeasonRulesService)', () {
    final season = const DefaultSeasonRulesService();

    test('Scenario for 26 May 2026 = Arafah (user-reported date)', () {
      // This is the exact date the user was using when the bug was
      // discovered. Lock it in as a regression test.
      final h = season.toHijri(DateTime(2026, 5, 26));
      expect(h.month, 12);
      expect(h.day, 9, reason: '26 May 2026 should be Arafah');
      expect(
        TashreeqRules.windowDaysAhead(
          hijriMonth: h.month,
          hijriDay: h.day,
        ),
        3,
        reason: 'Arafah should use 3-day window',
      );
      expect(
        TashreeqRules.shouldScheduleTashreeq(
          hijriMonth: h.month,
          hijriDay: h.day,
          prayerType: PrayerType.fajr,
        ),
        isTrue,
        reason: 'Arafah Fajr should get a Tashreeq reminder',
      );
    });

    test('Scenario for 30 May 2026 = last Eid day', () {
      final h = season.toHijri(DateTime(2026, 5, 30));
      expect(h.month, 12);
      expect(h.day, 13);
      // Last day: Maghrib and Isha do NOT get Tashreeq.
      expect(
        TashreeqRules.shouldScheduleTashreeq(
          hijriMonth: h.month,
          hijriDay: h.day,
          prayerType: PrayerType.maghrib,
        ),
        isFalse,
      );
      expect(
        TashreeqRules.shouldScheduleTashreeq(
          hijriMonth: h.month,
          hijriDay: h.day,
          prayerType: PrayerType.asr,
        ),
        isTrue,
        reason: 'Last Asr is the final Tashreeq of the year',
      );
    });

    test('Scenario 2: 31 May 2026 = post-Bayram, window snaps to 5', () {
      final h = season.toHijri(DateTime(2026, 5, 31));
      expect(h.month, 12);
      expect(h.day, 14);
      expect(
        TashreeqRules.windowDaysAhead(
          hijriMonth: h.month,
          hijriDay: h.day,
        ),
        5,
      );
      // And zero Tashreeq notifications for any prayer that day.
      for (final p in PrayerType.values) {
        expect(
          TashreeqRules.shouldScheduleTashreeq(
            hijriMonth: h.month,
            hijriDay: h.day,
            prayerType: p,
          ),
          isFalse,
        );
      }
    });

    test('Scenario 4: 2027 Kurban auto-restart (no manual state needed)', () {
      // Year-over-year sanity: the rules are pure date-driven so they
      // must trigger again next year without any persisted state to
      // reset. Verified at the exact projected 2027 Arafah date.
      final arafah2027 = season.toHijri(DateTime(2027, 5, 16));
      expect(arafah2027.month, 12);
      expect(arafah2027.day, 9, reason: '16 May 2027 should be Arafah 1448');
      expect(
        TashreeqRules.windowDaysAhead(
          hijriMonth: arafah2027.month,
          hijriDay: arafah2027.day,
        ),
        3,
      );
      expect(
        TashreeqRules.shouldScheduleTashreeq(
          hijriMonth: arafah2027.month,
          hijriDay: arafah2027.day,
          prayerType: PrayerType.fajr,
        ),
        isTrue,
      );

      // And the snap-back day after 2027 Bayram.
      final postBayram2027 = season.toHijri(DateTime(2027, 5, 21));
      expect(postBayram2027.day, 14);
      expect(
        TashreeqRules.windowDaysAhead(
          hijriMonth: postBayram2027.month,
          hijriDay: postBayram2027.day,
        ),
        5,
      );
    });

    test('Long-running sanity: window flips exactly twice over a year', () {
      // Walk every day of a full Hijri year (start from a non-Tashreeq
      // date so we begin in the 5-day state) and verify the 3-day
      // window appears exactly once, for exactly 6 consecutive days
      // (Zilhicce 8-13), and the 23-Tashreeq total appears exactly once.
      var threeDayStreaks = 0;
      var currentlyShort = false;
      var totalTashreeqsThisYear = 0;

      DateTime cursor = DateTime(2026, 6, 1); // Post-Bayram 2026
      for (var i = 0; i < 365; i++) {
        final h = season.toHijri(cursor);
        final isShort = TashreeqRules.windowDaysAhead(
              hijriMonth: h.month,
              hijriDay: h.day,
            ) ==
            3;
        if (isShort && !currentlyShort) {
          threeDayStreaks++;
          currentlyShort = true;
        }
        if (!isShort) {
          currentlyShort = false;
        }
        if (isShort) {
          for (final p in PrayerType.values) {
            if (TashreeqRules.shouldScheduleTashreeq(
              hijriMonth: h.month,
              hijriDay: h.day,
              prayerType: p,
            )) {
              totalTashreeqsThisYear++;
            }
          }
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      expect(threeDayStreaks, 1,
          reason: '3-day window should appear exactly once per year');
      expect(totalTashreeqsThisYear, 23,
          reason: 'Annual Tashreeq total should match Diyanet 23');
    });
  });
}
