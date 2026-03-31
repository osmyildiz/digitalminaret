import 'package:digitalminaret/data/models/settings_model.dart';

class FakeSettingsRepository {
  FakeSettingsRepository({required SettingsModel initial}) : _current = initial;

  SettingsModel _current;

  Future<SettingsModel> load() async => _current;

  Future<void> save(SettingsModel settings) async {
    _current = settings;
  }
}
