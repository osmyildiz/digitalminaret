import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/location_model.dart';
import '../models/prayer_times_model.dart';
import '../models/settings_model.dart';

class StorageService {
  StorageService({SharedPreferences? sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  final SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> get _prefs async {
    return _sharedPreferences ?? SharedPreferences.getInstance();
  }

  Future<void> saveLocation(LocationModel location) async {
    final prefs = await _prefs;
    await prefs.setString(
      AppConstants.locationStorageKey,
      jsonEncode(location.toJson()),
    );
  }

  Future<LocationModel?> getLocation() async {
    final prefs = await _prefs;
    final raw = prefs.getString(AppConstants.locationStorageKey);
    if (raw == null) {
      return null;
    }
    return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await _prefs;
    await prefs.setString(
      AppConstants.settingsStorageKey,
      jsonEncode(settings.toJson()),
    );
  }

  Future<SettingsModel> getSettings() async {
    final prefs = await _prefs;
    final raw = prefs.getString(AppConstants.settingsStorageKey);
    if (raw == null) {
      return SettingsModel.defaults();
    }
    return SettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> hasSettingsBeenSaved() async {
    final prefs = await _prefs;
    return prefs.containsKey(AppConstants.settingsStorageKey);
  }

  Future<void> savePrayerTimes(PrayerTimesModel times) async {
    final prefs = await _prefs;
    await prefs.setString(
      AppConstants.prayerTimesStorageKey,
      jsonEncode(times.toJson()),
    );
  }

  Future<PrayerTimesModel?> getPrayerTimes() async {
    final prefs = await _prefs;
    final raw = prefs.getString(AppConstants.prayerTimesStorageKey);
    if (raw == null) {
      return null;
    }
    return PrayerTimesModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<int> incrementAppOpenCount() async {
    final prefs = await _prefs;
    final current = prefs.getInt(AppConstants.appOpenCountKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(AppConstants.appOpenCountKey, next);
    return next;
  }

  Future<int> getAppOpenCount() async {
    final prefs = await _prefs;
    return prefs.getInt(AppConstants.appOpenCountKey) ?? 0;
  }

  Future<void> setHasRated(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(AppConstants.hasRatedKey, value);
  }

  Future<bool> getHasRated() async {
    final prefs = await _prefs;
    return prefs.getBool(AppConstants.hasRatedKey) ?? false;
  }

  Future<void> setLastTimezoneOffsetMinutes(int minutes) async {
    final prefs = await _prefs;
    await prefs.setInt(AppConstants.timezoneOffsetMinutesKey, minutes);
  }

  Future<int?> getLastTimezoneOffsetMinutes() async {
    final prefs = await _prefs;
    return prefs.getInt(AppConstants.timezoneOffsetMinutesKey);
  }
}
