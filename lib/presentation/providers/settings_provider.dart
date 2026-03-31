import 'package:flutter/foundation.dart';

import '../../data/models/settings_model.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  SettingsModel _settings = SettingsModel.defaults();

  SettingsModel get settings => _settings;

  Future<void> loadSettings() async {
    _settings = await _settingsRepository.getSettings();
    notifyListeners();
  }

  Future<void> saveSettings(SettingsModel settings) async {
    _settings = settings;
    await _settingsRepository.saveSettings(settings);
    notifyListeners();
  }
}
