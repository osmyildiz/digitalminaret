import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Pushes the current prayer-time snapshot to the paired Wear OS device
/// via Google's Wearable DataLayer. iOS-side equivalent is the App
/// Group write inside `WidgetService.sendDataToWidget` that the Apple
/// Watch app already reads directly — so this service is Android-only.
class WearSyncService {
  WearSyncService._internal();
  static final WearSyncService _instance = WearSyncService._internal();
  factory WearSyncService() => _instance;

  static const MethodChannel _channel =
      MethodChannel('com.osmyildiz.digitalminaret/wear');

  Future<void> push({
    required String location,
    required Map<String, int> epochsByPrayerKey,
    required Map<String, String> namesByPrayerKey,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<bool>('push', <String, Object?>{
        'location': location,
        'epochs': epochsByPrayerKey,
        'names': namesByPrayerKey,
      });
    } on PlatformException catch (error) {
      debugPrint('[WearSync] push failed: $error');
    } on MissingPluginException {
      // Native bridge not loaded yet — skip silently.
    }
  }
}
