import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/enums/prayer_type.dart';
import '../models/prayer_times_model.dart';

/// Unified "live status" surface: iOS Live Activity (lock screen + Dynamic
/// Island) and Android ongoing foreground-style notification. Both share
/// the same method channel name so Flutter only has to call once.
///
/// Native bridges:
/// - iOS:     ios/Runner/AppDelegate.swift
/// - Android: android/app/src/main/kotlin/.../MainActivity.kt
class LiveActivityService {
  LiveActivityService._internal();
  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;

  static const MethodChannel _channel =
      MethodChannel('com.osmyildiz.digitalminaret/live_activity');

  bool? _supportedCache;

  Future<bool> isSupported() async {
    if (kIsWeb) return false;
    if (!Platform.isIOS && !Platform.isAndroid) return false;
    if (_supportedCache != null) return _supportedCache!;
    try {
      final raw = await _channel.invokeMethod<bool>('isSupported');
      _supportedCache = raw ?? false;
      return _supportedCache!;
    } on PlatformException catch (error) {
      debugPrint('[LiveActivity] isSupported failed: $error');
      _supportedCache = false;
      return false;
    } on MissingPluginException {
      _supportedCache = false;
      return false;
    }
  }

  /// Start or refresh the lock-screen activity. Both platforms accept the
  /// same payload — iOS uses the epoch fields (so SwiftUI's timerInterval
  /// can auto-tick) and ignores the text fields, while Android uses the
  /// pre-formatted text fields (since RemoteViews has no live timer).
  Future<void> startOrUpdate({
    required PrayerTimesModel times,
    required PrayerType activePrayer,
    required DateTime activePrayerTime,
    required PrayerType nextPrayer,
    required DateTime nextPrayerTime,
    required String activePrayerLocalized,
    required String nextPrayerLocalized,
    required String activePrayerArabic,
  }) async {
    if (!await isSupported()) return;

    final now = DateTime.now();
    final remaining = nextPrayerTime.difference(now);
    final periodTotal = nextPrayerTime.difference(activePrayerTime).inSeconds;
    final periodElapsed = now.difference(activePrayerTime).inSeconds;
    final progress = periodTotal <= 0
        ? 0
        : ((periodElapsed / periodTotal) * 100).clamp(0, 100).toInt();

    final args = <String, Object?>{
      'activePrayer': activePrayerLocalized,
      'activePrayerArabic': activePrayerArabic,
      'activePrayerEpochMs': activePrayerTime.millisecondsSinceEpoch,
      'activePrayerTimeText': _formatClock(activePrayerTime),
      'nextPrayer': nextPrayerLocalized,
      'nextPrayerEpochMs': nextPrayerTime.millisecondsSinceEpoch,
      'nextPrayerTimeText': _formatClock(nextPrayerTime),
      'location': times.locationName,
      'remainingText': _formatRemaining(remaining),
      'progressPercent': progress,
    };

    try {
      // Try update first; if no activity exists the native side returns
      // false (iOS) and we fall through to start. Android's update path
      // also creates if missing, so the start branch is iOS-only in
      // practice.
      final updated = await _channel.invokeMethod<bool>('update', args);
      if (updated == true) return;
      await _channel.invokeMethod<String>('start', args);
    } on PlatformException catch (error) {
      debugPrint('[LiveActivity] startOrUpdate failed: $error');
    } on MissingPluginException {
      // Native bridge not wired (e.g. first run before rebuild).
    }
  }

  Future<void> end() async {
    if (!await isSupported()) return;
    try {
      await _channel.invokeMethod<bool>('end');
    } on PlatformException catch (error) {
      debugPrint('[LiveActivity] end failed: $error');
    } on MissingPluginException {
      // No-op.
    }
  }

  String _formatClock(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  String _formatRemaining(Duration d) {
    final safe = d.isNegative ? Duration.zero : d;
    final h = safe.inHours;
    final m = safe.inMinutes.remainder(60);
    if (h == 0) {
      return '${m.toString().padLeft(2, '0')}m';
    }
    return '${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m';
  }
}
