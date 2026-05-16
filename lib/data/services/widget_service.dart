import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/enums/prayer_type.dart';
import '../models/prayer_times_model.dart';
import 'live_activity_service.dart';
import 'wear_sync_service.dart';

class WidgetService {
  WidgetService({
    LiveActivityService? liveActivityService,
    WearSyncService? wearSyncService,
  })  : _liveActivityService = liveActivityService ?? LiveActivityService(),
        _wearSyncService = wearSyncService ?? WearSyncService();

  final LiveActivityService _liveActivityService;
  final WearSyncService _wearSyncService;

  static const String _appGroupId = 'group.com.osmyildiz.digitalminaret';
  static const String _iosWidgetKind = 'PrayerWidget';

  /// Maps locale code to localized prayer names.
  static const Map<String, Map<PrayerType, String>> _localizedNames = {
    'en': {
      PrayerType.fajr: 'Fajr',
      PrayerType.sunrise: 'Sunrise',
      PrayerType.dhuhr: 'Dhuhr',
      PrayerType.asr: 'Asr',
      PrayerType.maghrib: 'Maghrib',
      PrayerType.isha: 'Isha',
    },
    'tr': {
      PrayerType.fajr: 'Sabah',
      PrayerType.sunrise: 'Güneş',
      PrayerType.dhuhr: 'Öğle',
      PrayerType.asr: 'İkindi',
      PrayerType.maghrib: 'Akşam',
      PrayerType.isha: 'Yatsı',
    },
    'ar': {
      PrayerType.fajr: 'الفجر',
      PrayerType.sunrise: 'الشروق',
      PrayerType.dhuhr: 'الظهر',
      PrayerType.asr: 'العصر',
      PrayerType.maghrib: 'المغرب',
      PrayerType.isha: 'العشاء',
    },
    'ur': {
      PrayerType.fajr: 'فجر',
      PrayerType.sunrise: 'طلوع آفتاب',
      PrayerType.dhuhr: 'ظہر',
      PrayerType.asr: 'عصر',
      PrayerType.maghrib: 'مغرب',
      PrayerType.isha: 'عشاء',
    },
    'id': {
      PrayerType.fajr: 'Subuh',
      PrayerType.sunrise: 'Terbit',
      PrayerType.dhuhr: 'Dzuhur',
      PrayerType.asr: 'Ashar',
      PrayerType.maghrib: 'Maghrib',
      PrayerType.isha: 'Isya',
    },
    'fr': {
      PrayerType.fajr: 'Fajr',
      PrayerType.sunrise: 'Chourouk',
      PrayerType.dhuhr: 'Dohr',
      PrayerType.asr: 'Asr',
      PrayerType.maghrib: 'Maghrib',
      PrayerType.isha: 'Isha',
    },
    'fa': {
      PrayerType.fajr: 'فجر',
      PrayerType.sunrise: 'طلوع آفتاب',
      PrayerType.dhuhr: 'ظهر',
      PrayerType.asr: 'عصر',
      PrayerType.maghrib: 'مغرب',
      PrayerType.isha: 'عشاء',
    },
    'ja': {
      PrayerType.fajr: 'ファジュル',
      PrayerType.sunrise: '日の出',
      PrayerType.dhuhr: 'ドゥフル',
      PrayerType.asr: 'アスル',
      PrayerType.maghrib: 'マグリブ',
      PrayerType.isha: 'イシャー',
    },
  };

  Future<void> updateWidget(
    PrayerTimesModel times, {
    String locale = 'en',
  }) async {
    final map = <PrayerType, DateTime>{
      PrayerType.fajr: times.fajr.toLocal(),
      PrayerType.sunrise: times.sunrise.toLocal(),
      PrayerType.dhuhr: times.dhuhr.toLocal(),
      PrayerType.asr: times.asr.toLocal(),
      PrayerType.maghrib: times.maghrib.toLocal(),
      PrayerType.isha: times.isha.toLocal(),
    };
    final now = DateTime.now();
    final ordered = map.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    var next = ordered.first;
    for (final item in ordered) {
      if (item.value.isAfter(now)) {
        next = item;
        break;
      }
    }
    if (!next.value.isAfter(now)) {
      next = MapEntry(next.key, next.value.add(const Duration(days: 1)));
    }
    final current = _findCurrentPrayer(now, ordered);
    final remaining = next.value.difference(now);
    final previousPrayerTime = current.value;
    final progress = _computeProgress(
      now: now,
      start: previousPrayerTime,
      end: next.value,
    );

    final names = _localizedNames[locale] ?? _localizedNames['en']!;

    await sendDataToWidget(
      locationName: times.locationName,
      activePrayer: names[current.key] ?? current.key.name,
      activePrayerEpochMs: current.value.millisecondsSinceEpoch,
      nextPrayer: names[next.key] ?? next.key.name,
      nextPrayerTime: next.value.toIso8601String(),
      nextPrayerEpochMs: next.value.millisecondsSinceEpoch,
      timeRemaining: _durationText(remaining),
      currentPrayerStartEpochMs: previousPrayerTime.millisecondsSinceEpoch,
      currentPrayerEndEpochMs: next.value.millisecondsSinceEpoch,
      progress: progress,
      allPrayers: {
        for (final entry in map.entries)
          entry.key.name: entry.value.toIso8601String(),
      },
      allPrayersEpochMs: {
        for (final entry in map.entries)
          entry.key.name: entry.value.millisecondsSinceEpoch,
      },
      localizedPrayerNames: {
        for (final entry in map.entries)
          entry.key.name: names[entry.key] ?? entry.key.name,
      },
      locale: locale,
    );

    // Push the same snapshot to the iOS Live Activity (no-op elsewhere).
    // Activity countdown auto-ticks via SwiftUI's Text(timerInterval:),
    // so we only need to push when the active/next prayer flips —
    // i.e. each time prayer times are recomputed.
    // Full ordered day schedule (Fajr → Isha) for the proportional
    // Live Activity timeline.
    final schedule = <Map<String, Object>>[
      for (final entry in ordered)
        {
          'name': names[entry.key] ?? entry.key.name,
          'epochMs': entry.value.millisecondsSinceEpoch,
        },
    ];

    await _liveActivityService.startOrUpdate(
      times: times,
      activePrayer: current.key,
      activePrayerTime: previousPrayerTime,
      nextPrayer: next.key,
      nextPrayerTime: next.value,
      activePrayerLocalized: names[current.key] ?? current.key.name,
      nextPrayerLocalized: names[next.key] ?? next.key.name,
      activePrayerArabic: _arabicByPrayer(current.key, previousPrayerTime),
      schedule: schedule,
    );

    // Push to paired Wear OS device — Android-only, silent no-op
    // if no watch is paired or Play Services is missing.
    await _wearSyncService.push(
      location: times.locationName,
      epochsByPrayerKey: {
        for (final entry in map.entries)
          entry.key.name: entry.value.millisecondsSinceEpoch,
      },
      namesByPrayerKey: {
        for (final entry in map.entries)
          entry.key.name: names[entry.key] ?? entry.key.name,
      },
    );
  }

  static const Map<PrayerType, String> _arabicNames = {
    PrayerType.fajr: 'فجر',
    PrayerType.sunrise: 'شروق',
    PrayerType.dhuhr: 'ظهر',
    PrayerType.asr: 'عصر',
    PrayerType.maghrib: 'مغرب',
    PrayerType.isha: 'عشاء',
  };

  String _arabicByPrayer(PrayerType type, DateTime time) {
    if (type == PrayerType.dhuhr && time.weekday == DateTime.friday) {
      return 'جمعة';
    }
    return _arabicNames[type] ?? '';
  }

  Future<void> sendDataToWidget({
    required String locationName,
    required String activePrayer,
    required int activePrayerEpochMs,
    required String nextPrayer,
    required String nextPrayerTime,
    required int nextPrayerEpochMs,
    required String timeRemaining,
    required int currentPrayerStartEpochMs,
    required int currentPrayerEndEpochMs,
    required double progress,
    required Map<String, String> allPrayers,
    required Map<String, int> allPrayersEpochMs,
    required Map<String, String> localizedPrayerNames,
    required String locale,
  }) async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.saveWidgetData<String>('active_prayer', activePrayer);
    await HomeWidget.saveWidgetData<int>('active_prayer_epoch_ms', activePrayerEpochMs);
    await HomeWidget.saveWidgetData<String>('location_name', locationName);
    await HomeWidget.saveWidgetData<String>('next_prayer', nextPrayer);
    await HomeWidget.saveWidgetData<String>('next_prayer_time', nextPrayerTime);
    await HomeWidget.saveWidgetData<int>('next_prayer_epoch_ms', nextPrayerEpochMs);
    await HomeWidget.saveWidgetData<String>('time_remaining', timeRemaining);
    await HomeWidget.saveWidgetData<int>(
      'current_prayer_start_epoch_ms',
      currentPrayerStartEpochMs,
    );
    await HomeWidget.saveWidgetData<int>(
      'current_prayer_end_epoch_ms',
      currentPrayerEndEpochMs,
    );
    await HomeWidget.saveWidgetData<double>('current_prayer_progress', progress);
    await HomeWidget.saveWidgetData<String>('locale', locale);

    for (final entry in allPrayers.entries) {
      await HomeWidget.saveWidgetData<String>(
        'prayer_${entry.key}',
        entry.value,
      );
    }
    for (final entry in allPrayersEpochMs.entries) {
      await HomeWidget.saveWidgetData<int>(
        'prayer_${entry.key}_epoch_ms',
        entry.value,
      );
    }
    for (final entry in localizedPrayerNames.entries) {
      await HomeWidget.saveWidgetData<String>(
        'prayer_${entry.key}_name',
        entry.value,
      );
    }

    // Main update — works on both iOS (via iOSName) and Android (via the
    // `name` fallback, which matches the AppWidgetProvider class name).
    await HomeWidget.updateWidget(
      name: 'PrayerWidgetProvider',
      iOSName: _iosWidgetKind,
    );

    // Android has 3 additional widget sizes registered as separate
    // AppWidgetProvider classes; refresh each one. On iOS these calls
    // would fail because the plugin requires `name` or `iOSName` to be
    // non-null, so we guard by platform.
    if (!kIsWeb && Platform.isAndroid) {
      await HomeWidget.updateWidget(
        name: 'PrayerWidgetSmallProvider',
        androidName: 'PrayerWidgetSmallProvider',
      );
      await HomeWidget.updateWidget(
        name: 'PrayerWidgetMediumProvider',
        androidName: 'PrayerWidgetMediumProvider',
      );
      await HomeWidget.updateWidget(
        name: 'PrayerWidgetXLargeProvider',
        androidName: 'PrayerWidgetXLargeProvider',
      );
    }
  }

  String _durationText(Duration d) {
    final safe = d.isNegative ? Duration.zero : d;
    final h = safe.inHours;
    final m = safe.inMinutes.remainder(60);
    if (h == 0) {
      return '${m.toString().padLeft(2, '0')}m';
    }
    return '${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m';
  }

  MapEntry<PrayerType, DateTime> _findCurrentPrayer(
    DateTime now,
    List<MapEntry<PrayerType, DateTime>> ordered,
  ) {
    MapEntry<PrayerType, DateTime>? previous;
    for (final item in ordered) {
      if (!item.value.isAfter(now)) {
        previous = item;
      } else {
        break;
      }
    }
    if (previous != null) {
      return previous;
    }
    return MapEntry(
      ordered.last.key,
      ordered.last.value.subtract(const Duration(days: 1)),
    );
  }

  double _computeProgress({
    required DateTime now,
    required DateTime start,
    required DateTime end,
  }) {
    final totalMs = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    if (totalMs <= 0) {
      return 0;
    }
    final elapsedMs = now.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    final ratio = elapsedMs / totalMs;
    if (ratio.isNaN || ratio.isInfinite) {
      return 0;
    }
    return ratio.clamp(0.0, 1.0);
  }
}
