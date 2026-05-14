import 'package:adhan/adhan.dart' as adhan;

import '../../core/enums/calculation_method.dart';
import '../../core/enums/madhab.dart';
import '../models/prayer_times_model.dart';

class AdhanService {
  PrayerTimesModel calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required CalculationMethod method,
    required Madhab madhab,
    String locationName = '',
  }) {
    final params = _mapMethod(method);
    params.madhab = _mapMadhab(madhab);
    // High-latitude rule: at |lat| >= ~48° (Sapporo, Stockholm, Helsinki,
    // Anchorage, north of Germany, etc.) Fajr/Isha angles can fail to reach
    // the horizon in summer, producing missing or absurd prayer times.
    // Middle-of-the-night ("gece yarısı") is the conservative scholarly
    // default and matches the package default; we set it explicitly so the
    // intent is visible and overridable later if the user wants to switch
    // to seventh-of-the-night or twilight-angle.
    params.highLatitudeRule = adhan.HighLatitudeRule.middle_of_the_night;
    final prayerTimes = adhan.PrayerTimes(
      adhan.Coordinates(latitude, longitude),
      adhan.DateComponents.from(date),
      params,
    );

    return PrayerTimesModel(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      date: DateTime(date.year, date.month, date.day),
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      calculationMethodName: method.name,
      madhabName: madhab.name,
    );
  }

  adhan.CalculationParameters _mapMethod(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.isna:
        return adhan.CalculationMethod.north_america.getParameters();
      case CalculationMethod.muslimWorldLeague:
        return adhan.CalculationMethod.muslim_world_league.getParameters();
      case CalculationMethod.turkeyDiyanet:
        return adhan.CalculationMethod.turkey.getParameters();
      case CalculationMethod.egyptian:
        return adhan.CalculationMethod.egyptian.getParameters();
      case CalculationMethod.karachi:
        return adhan.CalculationMethod.karachi.getParameters();
      case CalculationMethod.ummAlQura:
        return adhan.CalculationMethod.umm_al_qura.getParameters();
      case CalculationMethod.dubai:
        return adhan.CalculationMethod.dubai.getParameters();
      case CalculationMethod.singapore:
        return adhan.CalculationMethod.singapore.getParameters();
      case CalculationMethod.tehran:
        return adhan.CalculationMethod.tehran.getParameters();
    }
  }

  adhan.Madhab _mapMadhab(Madhab madhab) {
    switch (madhab) {
      case Madhab.nonHanafi:
        return adhan.Madhab.shafi;
      case Madhab.hanafi:
        return adhan.Madhab.hanafi;
    }
  }
}
