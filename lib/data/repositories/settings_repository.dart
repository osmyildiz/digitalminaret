import '../models/settings_model.dart';
import '../services/storage_service.dart';

class SettingsRepository {
  const SettingsRepository({required StorageService storageService})
    : _storageService = storageService;

  final StorageService _storageService;

  Future<SettingsModel> getSettings() {
    return _storageService.getSettings();
  }

  Future<void> saveSettings(SettingsModel settings) {
    return _storageService.saveSettings(settings);
  }
}
