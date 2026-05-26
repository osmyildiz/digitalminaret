import '../enums/prayer_type.dart';

/// Pure date-driven rules for the Tashreeq takbir notification window.
///
/// Extracted from NotificationService so the decisions (is today in the
/// Tashreeq period? how many days should we pre-schedule? does this
/// specific prayer get a Tashreeq reminder?) can be unit-tested without
/// dragging in flutter_local_notifications, shared_preferences, or the
/// AdhanService — none of which are needed to verify the rules.
///
/// Reference (Diyanet / Hanafi consensus): Tashreeq takbir is recited
/// after every fard prayer from Fajr of Arafah day (9 Zilhicce) through
/// Asr of the 4th Eid al-Adha day (13 Zilhicce). 23 fard prayers total.
class TashreeqRules {
  /// Hijri month index for Dhu al-Hijjah (Zilhicce). Months are
  /// 1-indexed in the converter we use, so this is 12, not 11.
  static const int _dhulHijjahMonth = 12;

  /// First Hijri day of the pre-schedule shrink. We start one day
  /// before Arafah (8 Zilhicce) so that on the evening of 8 Zilhicce
  /// the next-day Arafah Fajr Tashreeq is already in the budget under
  /// the tighter 3-day window. Without that buffer day, an opening on
  /// 8 Zilhicce evening would budget for 5 days, then the 9 Zilhicce
  /// reschedule would have to clear and rewrite anyway.
  static const int _shrinkStartDay = 8;

  /// Last Hijri day Tashreeq logic touches anything. After 13 Zilhicce
  /// the window snaps back to normal and Tashreeq notifications are no
  /// longer generated.
  static const int _shrinkEndDay = 13;

  /// First Hijri day with actual Tashreeq notifications (Arafah).
  static const int _tashreeqStartDay = 9;

  /// Last Hijri day with Tashreeq notifications (4th Eid day, partial).
  static const int _tashreeqEndDay = 13;

  /// Pre-schedule window during normal (non-Tashreeq) days.
  ///
  /// Sized for iOS's 64-pending-notification cap:
  ///   5 days × 6 prayers × 2 (reminder + actual) = 60
  ///   + 1 Jumuah Mubarak                          =  1
  ///   = 61, leaves headroom.
  static const int normalWindowDays = 5;

  /// Pre-schedule window during the Tashreeq period (Zilhicce 8-13).
  ///
  /// The extra Tashreeq notifications (up to 5 per day) push us over
  /// the iOS cap if we kept the 5-day window:
  ///   5 days × (12 prayer + 5 Tashreeq) + 1 Jumuah = 86  ✗ over 64
  ///   3 days × (12 prayer + 5 Tashreeq) + 1 Jumuah = 52  ✓ under 64
  static const int tashreeqWindowDays = 3;

  /// True if [hijriDay] in [hijriMonth] falls inside the period during
  /// which we narrow the pre-schedule window. Note this is wider than
  /// the period during which Tashreeq notifications are actually emitted
  /// (which starts on day 9, not day 8) — see [shouldScheduleTashreeq].
  static bool isInTashreeqPeriod({
    required int hijriMonth,
    required int hijriDay,
  }) {
    return hijriMonth == _dhulHijjahMonth &&
        hijriDay >= _shrinkStartDay &&
        hijriDay <= _shrinkEndDay;
  }

  /// Number of days to pre-schedule starting from today, given today's
  /// Hijri date. Returns [tashreeqWindowDays] inside the Tashreeq period
  /// and [normalWindowDays] otherwise.
  static int windowDaysAhead({
    required int hijriMonth,
    required int hijriDay,
  }) {
    return isInTashreeqPeriod(
      hijriMonth: hijriMonth,
      hijriDay: hijriDay,
    )
        ? tashreeqWindowDays
        : normalWindowDays;
  }

  /// True if a Tashreeq takbir reminder should be scheduled 10 minutes
  /// after the given [prayerType] on the given Hijri date.
  ///
  /// Rules (Diyanet / Hanafi):
  /// - Months other than Zilhicce: never.
  /// - Zilhicce 1-8 or 14+: never.
  /// - Zilhicce 9 (Arafah): every prayer except Sunrise (Fajr, Dhuhr,
  ///   Asr, Maghrib, Isha → 5).
  /// - Zilhicce 10-12 (Eid days 1-3): every prayer except Sunrise (5).
  /// - Zilhicce 13 (Eid day 4): only Fajr, Dhuhr, Asr (3). Maghrib /
  ///   Isha do NOT get a reminder because the takbir period ends after
  ///   Asr.
  /// - Sunrise (şuruk) never gets a Tashreeq reminder — it is not a
  ///   fard prayer.
  ///
  /// Total over the full period: 5 + 5 + 5 + 5 + 3 = 23 notifications.
  static bool shouldScheduleTashreeq({
    required int hijriMonth,
    required int hijriDay,
    required PrayerType prayerType,
  }) {
    if (hijriMonth != _dhulHijjahMonth) return false;
    if (hijriDay < _tashreeqStartDay || hijriDay > _tashreeqEndDay) {
      return false;
    }
    if (prayerType == PrayerType.sunrise) return false;
    if (hijriDay == _tashreeqEndDay) {
      // Day 13: only Fajr, Dhuhr, Asr.
      return prayerType == PrayerType.fajr ||
          prayerType == PrayerType.dhuhr ||
          prayerType == PrayerType.asr;
    }
    // Days 9-12: all fard prayers (sunrise already excluded above).
    return true;
  }
}
