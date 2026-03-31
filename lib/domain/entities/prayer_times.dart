import '../../core/enums/prayer_type.dart';

class PrayerTimes {
  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.locationName,
  });

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime date;
  final String locationName;

  Map<PrayerType, DateTime> asMap() {
    return {
      PrayerType.fajr: fajr,
      PrayerType.sunrise: sunrise,
      PrayerType.dhuhr: dhuhr,
      PrayerType.asr: asr,
      PrayerType.maghrib: maghrib,
      PrayerType.isha: isha,
    };
  }
}
