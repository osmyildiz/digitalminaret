import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../enums/prayer_type.dart';

class PrayerNames {
  static const Map<PrayerType, String> en = {
    PrayerType.fajr: 'Fajr',
    PrayerType.sunrise: 'Sunrise',
    PrayerType.dhuhr: 'Dhuhr',
    PrayerType.asr: 'Asr',
    PrayerType.maghrib: 'Maghrib',
    PrayerType.isha: 'Isha',
  };

  static String localized(BuildContext context, PrayerType type) {
    final l = AppLocalizations.of(context)!;
    switch (type) {
      case PrayerType.fajr:
        return l.prayerFajr;
      case PrayerType.sunrise:
        return l.prayerSunrise;
      case PrayerType.dhuhr:
        return l.prayerDhuhr;
      case PrayerType.asr:
        return l.prayerAsr;
      case PrayerType.maghrib:
        return l.prayerMaghrib;
      case PrayerType.isha:
        return l.prayerIsha;
    }
  }
}
