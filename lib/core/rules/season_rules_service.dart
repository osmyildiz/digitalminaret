abstract class SeasonRulesService {
  bool isRamadan(DateTime date, {String? cityName});

  HijriDate toHijri(DateTime date);

  String hijriDateText(DateTime date);

  String? eidPrayerLabel(DateTime date);
}

class DefaultSeasonRulesService implements SeasonRulesService {
  const DefaultSeasonRulesService();

  @override
  bool isRamadan(DateTime date, {String? cityName}) {
    return toHijri(date).month == 9;
  }

  @override
  HijriDate toHijri(DateTime g) {
    final a = ((14 - g.month) / 12).floor();
    final y = g.year + 4800 - a;
    final m = g.month + 12 * a - 3;
    final jdn =
        g.day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;

    final l = jdn - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l1 = l - 10631 * n + 354;
    final j =
        (((10985 - l1) / 5316).floor()) * (((50 * l1) / 17719).floor()) +
        ((l1 / 5670).floor()) * (((43 * l1) / 15238).floor());
    final l2 =
        l1 -
        (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) * (((15238 * j) / 43).floor()) +
        29;
    final month = (24 * l2 / 709).floor();
    final day = l2 - (709 * month / 24).floor();
    final year = 30 * n + j - 30;
    return HijriDate(year: year, month: month, day: day);
  }

  @override
  String hijriDateText(DateTime date) {
    final h = toHijri(date);
    final monthName = _hijriMonthNames[h.month - 1];
    return '${h.day} $monthName ${h.year} AH';
  }

  @override
  String? eidPrayerLabel(DateTime date) {
    final h = toHijri(date);
    if (h.month == 10 && h.day == 1) {
      return 'Eid al-Fitr Prayer';
    }
    if (h.month == 12 && h.day == 10) {
      return 'Eid al-Adha Prayer';
    }
    return null;
  }

  static const List<String> _hijriMonthNames = <String>[
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Shaaban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qadah',
    'Dhu al-Hijjah',
  ];
}

class HijriDate {
  const HijriDate({required this.year, required this.month, required this.day});

  final int year;
  final int month;
  final int day;
}
