class PrayerTimesModel {
  const PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.locationName,
    this.latitude,
    this.longitude,
    this.calculationMethodName,
    this.madhabName,
  });

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime date;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final String? calculationMethodName;
  final String? madhabName;

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
      'date': date.toIso8601String(),
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'calculationMethodName': calculationMethodName,
      'madhabName': madhabName,
    };
  }

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimesModel(
      fajr: DateTime.parse(json['fajr'] as String),
      sunrise: DateTime.parse(json['sunrise'] as String),
      dhuhr: DateTime.parse(json['dhuhr'] as String),
      asr: DateTime.parse(json['asr'] as String),
      maghrib: DateTime.parse(json['maghrib'] as String),
      isha: DateTime.parse(json['isha'] as String),
      date: DateTime.parse(json['date'] as String),
      locationName: json['locationName'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      calculationMethodName: json['calculationMethodName'] as String?,
      madhabName: json['madhabName'] as String?,
    );
  }
}
