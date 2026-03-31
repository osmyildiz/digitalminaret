import '../../core/enums/calculation_method.dart';
import '../../core/enums/madhab.dart';
import '../../core/enums/prayer_type.dart';

class UserSettings {
  const UserSettings({
    required this.calculationMethod,
    required this.madhab,
    required this.notificationsEnabled,
    required this.adhanSoundEnabled,
    required this.enabledPrayers,
  });

  final CalculationMethod calculationMethod;
  final Madhab madhab;
  final bool notificationsEnabled;
  final bool adhanSoundEnabled;
  final Map<PrayerType, bool> enabledPrayers;
}
