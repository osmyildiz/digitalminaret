import '../../core/enums/calculation_method.dart';
import '../../core/enums/madhab.dart';
import '../../core/enums/prayer_alert_mode.dart';
import '../../core/enums/prayer_type.dart';
import '../../core/constants/adhan_packs.dart';

class SettingsModel {
  const SettingsModel({
    required this.calculationMethod,
    required this.madhab,
    required this.selectedAdhanPackId,
    required this.notificationsEnabled,
    required this.adhanSoundEnabled,
    required this.postAdhanDuaEnabled,
    required this.enabledPrayers,
    required this.prayerAlertModes,
    this.locale = 'en',
  });

  final CalculationMethod calculationMethod;
  final Madhab madhab;
  final String selectedAdhanPackId;
  final bool notificationsEnabled;
  final bool adhanSoundEnabled;
  final bool postAdhanDuaEnabled;
  final Map<PrayerType, bool> enabledPrayers;
  final Map<PrayerType, PrayerAlertMode> prayerAlertModes;
  final String locale;

  factory SettingsModel.defaults() {
    return const SettingsModel(
      calculationMethod: CalculationMethod.isna,
      madhab: Madhab.nonHanafi,
      selectedAdhanPackId: AdhanPacks.defaultPackId,
      notificationsEnabled: true,
      adhanSoundEnabled: true,
      postAdhanDuaEnabled: true,
      enabledPrayers: {
        PrayerType.fajr: true,
        PrayerType.sunrise: false,
        PrayerType.dhuhr: true,
        PrayerType.asr: true,
        PrayerType.maghrib: true,
        PrayerType.isha: true,
      },
      prayerAlertModes: {
        PrayerType.fajr: PrayerAlertMode.sound,
        PrayerType.sunrise: PrayerAlertMode.off,
        PrayerType.dhuhr: PrayerAlertMode.sound,
        PrayerType.asr: PrayerAlertMode.sound,
        PrayerType.maghrib: PrayerAlertMode.sound,
        PrayerType.isha: PrayerAlertMode.sound,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calculationMethod': calculationMethod.name,
      'madhab': madhab.name,
      'selectedAdhanPackId': selectedAdhanPackId,
      'notificationsEnabled': notificationsEnabled,
      'adhanSoundEnabled': adhanSoundEnabled,
      'postAdhanDuaEnabled': postAdhanDuaEnabled,
      'enabledPrayers': enabledPrayers.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'prayerAlertModes': prayerAlertModes.map(
        (key, value) => MapEntry(key.name, value.name),
      ),
      'locale': locale,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    final enabledPrayersJson =
        json['enabledPrayers'] as Map<String, dynamic>? ?? {};
    final prayerAlertModesJson =
        json['prayerAlertModes'] as Map<String, dynamic>? ?? {};

    return SettingsModel(
      calculationMethod: CalculationMethod.values.firstWhere(
        (e) => e.name == json['calculationMethod'],
        orElse: () => CalculationMethod.isna,
      ),
      madhab: Madhab.values.firstWhere(
        (e) => e.name == json['madhab'],
        orElse: () => Madhab.nonHanafi,
      ),
      selectedAdhanPackId:
          json['selectedAdhanPackId'] as String? ?? AdhanPacks.defaultPackId,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      adhanSoundEnabled: json['adhanSoundEnabled'] as bool? ?? true,
      postAdhanDuaEnabled: json['postAdhanDuaEnabled'] as bool? ?? true,
      enabledPrayers: {
        for (final prayer in PrayerType.values)
          prayer: enabledPrayersJson[prayer.name] as bool? ?? true,
      },
      prayerAlertModes: {
        for (final prayer in PrayerType.values)
          prayer: _parsePrayerAlertMode(
            rawValue: prayerAlertModesJson[prayer.name],
            fallbackEnabled: enabledPrayersJson[prayer.name] as bool? ?? true,
          ),
      },
      locale: json['locale'] as String? ?? 'en',
    );
  }

  SettingsModel copyWith({
    CalculationMethod? calculationMethod,
    Madhab? madhab,
    String? selectedAdhanPackId,
    bool? notificationsEnabled,
    bool? adhanSoundEnabled,
    bool? postAdhanDuaEnabled,
    Map<PrayerType, bool>? enabledPrayers,
    Map<PrayerType, PrayerAlertMode>? prayerAlertModes,
    String? locale,
  }) {
    return SettingsModel(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      selectedAdhanPackId: selectedAdhanPackId ?? this.selectedAdhanPackId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      adhanSoundEnabled: adhanSoundEnabled ?? this.adhanSoundEnabled,
      postAdhanDuaEnabled: postAdhanDuaEnabled ?? this.postAdhanDuaEnabled,
      enabledPrayers: enabledPrayers ?? this.enabledPrayers,
      prayerAlertModes: prayerAlertModes ?? this.prayerAlertModes,
      locale: locale ?? this.locale,
    );
  }

  static PrayerAlertMode _parsePrayerAlertMode({
    required dynamic rawValue,
    required bool fallbackEnabled,
  }) {
    if (rawValue is String) {
      return PrayerAlertMode.values.firstWhere(
        (mode) => mode.name == rawValue,
        orElse: () =>
            fallbackEnabled ? PrayerAlertMode.sound : PrayerAlertMode.off,
      );
    }
    return fallbackEnabled ? PrayerAlertMode.sound : PrayerAlertMode.off;
  }
}
