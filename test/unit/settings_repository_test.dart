// Guarantees settings defaults, persistence and fallback behavior.
import 'package:digitalminaret/core/enums/calculation_method.dart';
import 'package:digitalminaret/data/models/settings_model.dart';
import 'package:digitalminaret/data/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('default settings are returned on first install', () async {
    final settings = await StorageService().getSettings();
    expect(settings.calculationMethod, CalculationMethod.isna);
    expect(settings.notificationsEnabled, isTrue);
    expect(settings.selectedAdhanPackId.isNotEmpty, isTrue);
  });

  test('saved settings survive restart simulation', () async {
    final storage1 = StorageService();
    final initial = await storage1.getSettings();
    await storage1.saveSettings(
      initial.copyWith(
        calculationMethod: CalculationMethod.egyptian,
        notificationsEnabled: false,
      ),
    );

    final storage2 = StorageService();
    final reread = await storage2.getSettings();

    expect(reread.calculationMethod, CalculationMethod.egyptian);
    expect(reread.notificationsEnabled, isFalse);
  });

  test('invalid json map falls back safely', () {
    final parsed = SettingsModel.fromJson(<String, dynamic>{'x': 'y'});
    expect(parsed.calculationMethod, CalculationMethod.isna);
    expect(parsed.madhab.name, isNotEmpty);
  });

  test('partial json falls back for missing fields', () {
    final parsed = SettingsModel.fromJson(<String, dynamic>{
      'calculationMethod': 'isna',
      'notificationsEnabled': false,
    });

    expect(parsed.calculationMethod, CalculationMethod.isna);
    expect(parsed.notificationsEnabled, isFalse);
    expect(parsed.selectedAdhanPackId.isNotEmpty, isTrue);
  });
}
