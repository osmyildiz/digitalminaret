class PrayerLabelResolver {
  const PrayerLabelResolver();

  String resolve({
    required String prayerName,
    required DateTime date,
    required bool isRamadan,
    String suhoorLabel = 'Suhoor',
  }) {
    final normalized = prayerName.trim();
    if (normalized.isEmpty) {
      return prayerName;
    }

    if (_equals(normalized, 'dhuhr')) {
      return date.weekday == DateTime.friday ? 'Jumuah' : 'Dhuhr';
    }

    if (_equals(normalized, 'maghrib')) {
      return isRamadan ? 'Iftar' : 'Maghrib';
    }

    if (_equals(normalized, 'fajr')) {
      return isRamadan ? suhoorLabel : 'Fajr';
    }

    return _canonicalOrOriginal(normalized, prayerName);
  }

  bool _equals(String a, String b) => a.toLowerCase() == b.toLowerCase();

  String _canonicalOrOriginal(String normalized, String original) {
    const known = <String, String>{
      'fajr': 'Fajr',
      'sunrise': 'Sunrise',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
    };

    return known[normalized.toLowerCase()] ?? original;
  }
}
