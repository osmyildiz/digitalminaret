import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/adhan_playback_bus.dart';
import '../../core/constants/notification_ids.dart';
import '../../core/enums/calculation_method.dart';
import '../../core/enums/madhab.dart';
import '../../core/enums/prayer_alert_mode.dart';
import '../../core/enums/prayer_type.dart';
import '../models/prayer_times_model.dart';
import '../models/settings_model.dart';
import 'adhan_service.dart';

class NotificationService {
  NotificationService._internal({
    FlutterLocalNotificationsPlugin? plugin,
    AdhanService? adhanService,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _adhanService = adhanService ?? AdhanService();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  final AdhanService _adhanService;

  /// SharedPreferences key holding the date+location of the last successful
  /// full reschedule. Used to short-circuit repeated calls on the same day
  /// (e.g. multiple foregroundings) so we only do the heavy 5-day write once
  /// per day.
  static const String _lastRescheduleKey = 'notif_last_full_reschedule_v1';

  /// How far ahead to pre-schedule on a normal day. Bounded by iOS's hard
  /// 64-pending-notification cap: 5 days × 6 prayers × 2 (reminder+actual)
  /// = 60 + 1 Jumuah = 61, leaving headroom.
  static const int _normalDaysAhead = 5;

  /// During Tashreeq (Zilhicce 9–13) every prayer also gets a +10 min
  /// Tashreeq takbir reminder. Worst-case 5 prayers × 3 days of Tashreeq
  /// stacks on top of the regular notifications, so we drop the pre-schedule
  /// window from 5 → 3 days during that period to stay under 64.
  /// 3 days × (12 prayer + ~5 Tashreeq) + 1 Jumuah ≈ 52 notifications.
  static const int _tashreeqDaysAhead = 3;

  /// Localized notification strings per locale.
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'in_minutes': '{prayer} in 15 minutes',
      'prepare': 'You have 15 minutes to prepare.',
      'time': '{prayer} time',
      'started': 'Prayer time has started. Tap to listen to the adhan.',
      'tashreeq_title': 'Reminder: Takbir al-Tashreeq',
      'tashreeq_body': 'Do not forget the blessed Tashreeq takbir.',
      'jumuah': 'Jumu\'ah Mubarak',
    },
    'tr': {
      'in_minutes': '{prayer} vaktine 15 dakika',
      'prepare': 'Hazırlanmak için 15 dakikanız var.',
      'time': '{prayer} vakti',
      'started': 'Namaz vakti girdi. Ezan dinlemek için dokunun.',
      'tashreeq_title': 'Hatırlatma: Teşrik Tekbiri',
      'tashreeq_body': 'Mübarek teşrik tekbirini unutmayın.',
      'jumuah': 'Hayırlı Cumalar',
    },
    'ar': {
      'in_minutes': '{prayer} بعد 15 دقيقة',
      'prepare': 'لديك 15 دقيقة للاستعداد.',
      'time': 'وقت {prayer}',
      'started': 'حان وقت الصلاة. اضغط للاستماع إلى الأذان.',
      'tashreeq_title': 'تذكير: تكبيرات التشريق',
      'tashreeq_body': 'لا تنسَ تكبيرات التشريق المباركة.',
      'jumuah': 'جمعة مباركة',
    },
    'ur': {
      'in_minutes': '{prayer} میں 15 منٹ باقی',
      'prepare': 'تیاری کے لیے 15 منٹ باقی ہیں۔',
      'time': '{prayer} کا وقت',
      'started': 'نماز کا وقت ہو گیا۔ اذان سننے کے لیے ٹیپ کریں۔',
      'tashreeq_title': 'یاد دہانی: تکبیرات تشریق',
      'tashreeq_body': 'مبارک تشریق تکبیر مت بھولیں۔',
      'jumuah': 'جمعہ مبارک',
    },
    'id': {
      'in_minutes': '{prayer} 15 menit lagi',
      'prepare': 'Anda memiliki 15 menit untuk bersiap.',
      'time': 'Waktu {prayer}',
      'started': 'Waktu sholat telah tiba. Ketuk untuk mendengarkan adzan.',
      'tashreeq_title': 'Pengingat: Takbir Tasyrik',
      'tashreeq_body': 'Jangan lupa takbir tasyrik yang diberkahi.',
      'jumuah': 'Jumat Berkah',
    },
    'fr': {
      'in_minutes': '{prayer} dans 15 minutes',
      'prepare': 'Vous avez 15 minutes pour vous préparer.',
      'time': 'Heure de {prayer}',
      'started': 'L\'heure de la prière est arrivée. Appuyez pour écouter l\'adhan.',
      'tashreeq_title': 'Rappel : Takbir al-Tachrik',
      'tashreeq_body': 'N\'oubliez pas le takbir béni du Tachrik.',
      'jumuah': 'Joumou\'a Moubarak',
    },
    'fa': {
      'in_minutes': '{prayer} تا ۱۵ دقیقه دیگر',
      'prepare': '۱۵ دقیقه برای آمادگی فرصت دارید.',
      'time': 'وقت {prayer}',
      'started': 'وقت نماز فرا رسیده است. برای شنیدن اذان لمس کنید.',
      'tashreeq_title': 'یادآوری: تکبیرات تشریق',
      'tashreeq_body': 'تکبیرات تشریق مبارک را فراموش نکنید.',
      'jumuah': 'جمعه مبارک',
    },
    'ja': {
      'in_minutes': '{prayer}まであと15分',
      'prepare': '準備のためにあと15分あります。',
      'time': '{prayer}の時刻',
      'started': '礼拝の時刻になりました。タップしてアザーンを聞きます。',
      'tashreeq_title': 'リマインダー: タクビール・アッ=タシュリーク',
      'tashreeq_body': '祝福されたタシュリークのタクビールを忘れないでください。',
      'jumuah': 'ジュムア・ムバーラク',
    },
  };

  String _str(String locale, String key, {String? prayer}) {
    final map = _strings[locale] ?? _strings['en']!;
    final template = map[key] ?? _strings['en']![key] ?? key;
    if (prayer != null) {
      return template.replaceAll('{prayer}', prayer);
    }
    return template;
  }

  final FlutterLocalNotificationsPlugin _plugin;
  static const String _pendingTapPayloadKey =
      'pending_notification_tap_payload_v1';
  static String? _pendingPrayerFromLaunch;
  static String? _lastConsumedPayload;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
      ),
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    _initialized = true;

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    final launchPrayer = _parsePrayerNameFromPayload(payload);
    debugPrint(
      '[Notifications] launchDetails didLaunch='
      '${launchDetails?.didNotificationLaunchApp} payload='
      '$payload',
    );
    if (launchPrayer != null) {
      _lastConsumedPayload = payload;
      _pendingPrayerFromLaunch = launchPrayer;
      AdhanPlaybackBus.playFullAdhanPrayer.value = launchPrayer;
      debugPrint('[Notifications] queued launch prayer=$launchPrayer');
    }
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosLegacy = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final androidResult = await android?.requestNotificationsPermission();
    final iosLegacyResult = await iosLegacy?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final granted = (androidResult ?? true) && (iosLegacyResult ?? true);
    debugPrint(
      '[Notifications] requestPermission granted=$granted ios=$iosLegacyResult '
      'android=$androidResult',
    );
    return granted;
  }

  /// Pre-schedules prayer / reminder / Tashreeq notifications for the next
  /// N days. Idempotent within a single calendar day at the same location:
  /// repeated calls on the same day are skipped unless [forceRefresh] is set.
  ///
  /// Why this exists: the OS notification queue is one-shot — once a
  /// scheduled notification fires, it's gone, and iOS gives no reliable
  /// daily background-execution slot for re-scheduling. Pre-writing 5
  /// days at every fresh app open turns "user must open daily" into
  /// "user must open every 5 days" (or 3 days during Tashreeq, where the
  /// extra Tashreeq notifications eat into the 64-pending iOS budget).
  ///
  /// [forceRefresh] = true when settings or location change, so we always
  /// clear and rewrite even if we already wrote earlier today.
  Future<void> scheduleAllPrayerNotifications(
    PrayerTimesModel times,
    SettingsModel settings, {
    bool forceRefresh = false,
  }) async {
    if (!settings.notificationsEnabled) {
      await cancelAllNotifications();
      return;
    }

    // Idempotency: skip if we already wrote for today at this location.
    // Location is included so a trip (Istanbul → New York) invalidates
    // the cache automatically — same calendar day, different prayer times.
    final scheduleKey = _scheduleKey(times);
    if (!forceRefresh) {
      final prefs = await SharedPreferences.getInstance();
      final lastKey = prefs.getString(_lastRescheduleKey);
      if (lastKey == scheduleKey) {
        debugPrint('[Notifications] skip reschedule — already done for $scheduleKey');
        return;
      }
    }

    // Clear the entire queue and rewrite from scratch. Cheaper and
    // simpler than diffing per-ID; flutter_local_notifications handles
    // cancelAll quickly.
    await cancelAllNotifications();

    // Window size depends on whether we're in the Tashreeq period
    // (Zilhicce 9–13). Outside it, 5 days. Inside, 3 days so the extra
    // Tashreeq notifications fit under iOS's 64 cap.
    final todayHijri = _gregorianToHijri(times.date);
    final inTashreeqPeriod =
        todayHijri.month == 12 && todayHijri.day >= 8 && todayHijri.day <= 13;
    final daysAhead = inTashreeqPeriod ? _tashreeqDaysAhead : _normalDaysAhead;
    debugPrint(
      '[Notifications] reschedule window=$daysAhead days '
      '(tashreeq=$inTashreeqPeriod hijri=${todayHijri.day}/${todayHijri.month})',
    );

    // Walk each day in the window. Day 0 is the caller-provided times;
    // future days are computed from the same location / method / madhab
    // stored on the model.
    for (var dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      final dayTimes = dayOffset == 0
          ? times
          : _tryComputeFutureDay(times, dayOffset);
      if (dayTimes == null) {
        debugPrint(
          '[Notifications] skipping day +$dayOffset — could not compute times',
        );
        continue;
      }
      await _scheduleSingleDay(
        dayTimes: dayTimes,
        dayOffset: dayOffset,
        settings: settings,
      );
    }

    // Jumuah Mubarak fires on the next Friday at 10:00 regardless of
    // the schedule window, so it's outside the per-day loop and uses
    // a single fixed ID. (Future improvement: pre-write multiple
    // Fridays, but one is enough — Jumuah will reschedule itself on
    // the next app open.)
    await _scheduleJumuahMubarakNotification(settings.locale);

    // Persist the marker so same-day re-entries short-circuit.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRescheduleKey, scheduleKey);
  }

  /// Composite key combining the calendar date and rough location. Two
  /// fresh installs at the same lat/lon on the same date produce the
  /// same key; a flight to a different city produces a different one.
  String _scheduleKey(PrayerTimesModel times) {
    final d = times.date;
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    // Round lat/lon to 1 decimal — enough to invalidate on city change,
    // not so tight that GPS noise flaps the key for a stationary user.
    final lat = times.latitude?.toStringAsFixed(1) ?? '?';
    final lon = times.longitude?.toStringAsFixed(1) ?? '?';
    return '$dateStr|$lat,$lon';
  }

  /// Recompute prayer times for [today.date + dayOffset days] using the
  /// same lat/lon/method/madhab embedded in [today]. Returns null if any
  /// required field is missing — the caller then skips that day.
  PrayerTimesModel? _tryComputeFutureDay(
    PrayerTimesModel today,
    int dayOffset,
  ) {
    final lat = today.latitude;
    final lon = today.longitude;
    final methodName = today.calculationMethodName;
    final madhabName = today.madhabName;
    if (lat == null || lon == null || methodName == null || madhabName == null) {
      return null;
    }

    CalculationMethod? method;
    Madhab? madhab;
    for (final m in CalculationMethod.values) {
      if (m.name == methodName) {
        method = m;
        break;
      }
    }
    for (final m in Madhab.values) {
      if (m.name == madhabName) {
        madhab = m;
        break;
      }
    }
    if (method == null || madhab == null) {
      return null;
    }

    final futureDate = today.date.add(Duration(days: dayOffset));
    try {
      return _adhanService.calculatePrayerTimes(
        latitude: lat,
        longitude: lon,
        date: futureDate,
        method: method,
        madhab: madhab,
        locationName: today.locationName,
      );
    } catch (error) {
      debugPrint(
        '[Notifications] future-day calc failed for +$dayOffset: $error',
      );
      return null;
    }
  }

  /// Schedules one day's worth of prayer reminders + actual + Tashreeq
  /// notifications. Skips any notification whose scheduled time is in
  /// the past (so the same call works whether we're rewriting at 6 AM
  /// or 11 PM — past slots are simply omitted, not bumped to tomorrow).
  Future<void> _scheduleSingleDay({
    required PrayerTimesModel dayTimes,
    required int dayOffset,
    required SettingsModel settings,
  }) async {
    final locale = settings.locale;
    final names = _localizedPrayerNames[locale] ?? _localizedPrayerNames['en']!;
    final hijri = _gregorianToHijri(dayTimes.date);
    final isRamadan = hijri.month == 9;
    final now = DateTime.now();

    final map = <PrayerType, DateTime>{
      PrayerType.fajr: dayTimes.fajr,
      PrayerType.sunrise: dayTimes.sunrise,
      PrayerType.dhuhr: dayTimes.dhuhr,
      PrayerType.asr: dayTimes.asr,
      PrayerType.maghrib: dayTimes.maghrib,
      PrayerType.isha: dayTimes.isha,
    };

    for (final entry in map.entries) {
      final mode = settings.prayerAlertModes[entry.key] ??
          ((settings.enabledPrayers[entry.key] ?? true)
              ? PrayerAlertMode.sound
              : PrayerAlertMode.off);
      if (mode == PrayerAlertMode.off) continue;

      final prayerName = _localizedNotificationPrayerName(
        prayerType: entry.key,
        prayerTime: entry.value,
        names: names,
        isRamadan: isRamadan,
        locale: locale,
      );

      final reminderTime = entry.value.subtract(const Duration(minutes: 15));
      final tashreeqTime = entry.value.add(const Duration(minutes: 10));

      // -15 min reminder: critical UX ("the current prayer window is
      // about to close — last chance to pray Asr before Maghrib", etc.)
      // so we keep it even for far-future days. Past times are skipped.
      if (reminderTime.isAfter(now)) {
        await _scheduleOneShot(
          id: _reminderIdFor(entry.key, dayOffset),
          scheduledTime: reminderTime,
          title: _str(locale, 'in_minutes', prayer: prayerName),
          body: _str(locale, 'prepare'),
          alertMode: mode,
          prayerType: entry.key,
          playAdhanOnTap: false,
        );
      }
      if (entry.value.isAfter(now)) {
        await _scheduleOneShot(
          id: _prayerIdFor(entry.key, dayOffset),
          scheduledTime: entry.value,
          title: _str(locale, 'time', prayer: prayerName),
          body: _str(locale, 'started'),
          alertMode: mode,
          prayerType: entry.key,
          playAdhanOnTap: true,
        );
      }
      if (_shouldScheduleTashreeq(hijri: hijri, prayerType: entry.key) &&
          tashreeqTime.isAfter(now)) {
        await _scheduleOneShot(
          id: _tashreeqIdFor(entry.key, dayOffset),
          scheduledTime: tashreeqTime,
          title: '✨ ${_str(locale, 'tashreeq_title')} ✨',
          body: _str(locale, 'tashreeq_body'),
          alertMode: mode,
          prayerType: entry.key,
          playAdhanOnTap: false,
        );
      }
    }
  }

  /// Stride between consecutive days in the notification ID space. Each
  /// day's IDs sit 10 apart so day 0 fajr = 1, day 1 fajr = 11, etc.
  /// Range used: 1..146 (prayer) + 800..846 (Tashreeq), well within the
  /// 32-bit id space and never colliding with Jumuah (700).
  static const int _dayIdStride = 10;

  int _prayerIdFor(PrayerType type, int dayOffset) =>
      _notificationIdFor(type) + dayOffset * _dayIdStride;

  int _reminderIdFor(PrayerType type, int dayOffset) =>
      _notificationReminderIdFor(type) + dayOffset * _dayIdStride;

  int _tashreeqIdFor(PrayerType type, int dayOffset) =>
      _notificationTashreeqIdFor(type) + dayOffset * _dayIdStride;

  /// Variant of [scheduleSingleNotification] that assumes the caller has
  /// already verified scheduledTime is in the future. Skips the
  /// past-time → +1 day bumping that the legacy single-day path used,
  /// because in the multi-day world a "past" slot just means that day
  /// has already gone by, not that we want to silently shift it forward.
  Future<void> _scheduleOneShot({
    required int id,
    required DateTime scheduledTime,
    required String title,
    required String body,
    required PrayerAlertMode alertMode,
    required PrayerType prayerType,
    bool playAdhanOnTap = true,
  }) async {
    final schedule = tz.TZDateTime.from(scheduledTime, tz.local);
    debugPrint(
      '[Notifications] schedule id=$id at=$schedule '
      'mode=$alertMode prayer=${prayerType.name}',
    );
    final shouldPlaySound = alertMode == PrayerAlertMode.sound;
    final shouldVibrate = alertMode == PrayerAlertMode.vibrate ||
        alertMode == PrayerAlertMode.sound;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel',
        'Prayer Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: shouldPlaySound,
        enableVibration: shouldVibrate,
        silent: alertMode == PrayerAlertMode.silent,
        icon: 'ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
      ),
      iOS: DarwinNotificationDetails(
        presentSound: shouldPlaySound,
        presentBadge: true,
        presentAlert: true,
        presentBanner: true,
        presentList: true,
      ),
    );
    final payload = playAdhanOnTap ? _buildPayload(prayerType) : null;

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        schedule,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (error) {
      debugPrint(
        '[Notifications] exact schedule failed for id=$id, falling back. error=$error',
      );
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        schedule,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  Future<void> scheduleSingleNotification({
    required int id,
    required DateTime scheduledTime,
    required String title,
    required String body,
    required PrayerAlertMode alertMode,
    required PrayerType prayerType,
    bool playAdhanOnTap = true,
  }) async {
    var schedule = tz.TZDateTime.from(scheduledTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    if (!schedule.isAfter(now)) {
      schedule = schedule.add(const Duration(days: 1));
    }
    debugPrint(
      '[Notifications] schedule id=$id at=$schedule now=$now mode=$alertMode prayer=${prayerType.name}',
    );
    final shouldPlaySound = alertMode == PrayerAlertMode.sound;
    final shouldVibrate =
        alertMode == PrayerAlertMode.vibrate ||
        alertMode == PrayerAlertMode.sound;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel',
        'Prayer Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: shouldPlaySound,
        enableVibration: shouldVibrate,
        silent: alertMode == PrayerAlertMode.silent,
        icon: 'ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
      ),
      iOS: DarwinNotificationDetails(
        presentSound: shouldPlaySound,
        presentBadge: true,
        presentAlert: true,
        presentBanner: true,
        presentList: true,
      ),
    );
    final payload = playAdhanOnTap ? _buildPayload(prayerType) : null;

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        schedule,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (error) {
      debugPrint(
        '[Notifications] exact schedule failed for id=$id. '
        'Falling back to inexact. error=$error',
      );
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        schedule,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final prayerName = _parsePrayerNameFromPayload(response.payload);
    debugPrint(
      '[Notifications] onTap payload=${response.payload} prayer=$prayerName',
    );
    unawaited(_storeTapPayload(response.payload));
    _pendingPrayerFromLaunch = prayerName;
    AdhanPlaybackBus.playFullAdhanPrayer.value = prayerName;
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    // Wipe the "already rescheduled today" marker so the next call
    // doesn't short-circuit and leave the user with no notifications
    // after they re-enable them.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRescheduleKey);
  }

  Future<void> showInstantTestNotification({required int id}) {
    return _plugin.show(
      id,
      '✨ Premium Notification Test',
      'This is a live test. Tap to verify full adhan flow.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
        ),
      ),
      payload: 'play_full_adhan:isha',
    );
  }

  Future<void> cancelNotification(int id) {
    return _plugin.cancel(id);
  }

  Future<int> getPendingCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }

  int _notificationIdFor(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return NotificationIds.fajr;
      case PrayerType.sunrise:
        return NotificationIds.sunrise;
      case PrayerType.dhuhr:
        return NotificationIds.dhuhr;
      case PrayerType.asr:
        return NotificationIds.asr;
      case PrayerType.maghrib:
        return NotificationIds.maghrib;
      case PrayerType.isha:
        return NotificationIds.isha;
    }
  }

  int _notificationReminderIdFor(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return NotificationIds.fajrReminder;
      case PrayerType.sunrise:
        return NotificationIds.sunriseReminder;
      case PrayerType.dhuhr:
        return NotificationIds.dhuhrReminder;
      case PrayerType.asr:
        return NotificationIds.asrReminder;
      case PrayerType.maghrib:
        return NotificationIds.maghribReminder;
      case PrayerType.isha:
        return NotificationIds.ishaReminder;
    }
  }

  int _notificationTashreeqIdFor(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return NotificationIds.fajrTashreeq;
      case PrayerType.sunrise:
        return NotificationIds.sunriseTashreeq;
      case PrayerType.dhuhr:
        return NotificationIds.dhuhrTashreeq;
      case PrayerType.asr:
        return NotificationIds.asrTashreeq;
      case PrayerType.maghrib:
        return NotificationIds.maghribTashreeq;
      case PrayerType.isha:
        return NotificationIds.ishaTashreeq;
    }
  }

  bool _shouldScheduleTashreeq({
    required _HijriDate hijri,
    required PrayerType prayerType,
  }) {
    if (hijri.month != 12) {
      return false;
    }

    if (hijri.day < 9 || hijri.day > 13) {
      return false;
    }

    if (hijri.day == 9) {
      return prayerType != PrayerType.sunrise;
    }

    if (hijri.day == 13) {
      return prayerType == PrayerType.fajr ||
          prayerType == PrayerType.dhuhr ||
          prayerType == PrayerType.asr;
    }

    return prayerType != PrayerType.sunrise;
  }

  Future<void> _scheduleJumuahMubarakNotification(String locale) async {
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10, 0);
    var daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
    if (daysUntilFriday == 0 && !target.isAfter(now)) {
      daysUntilFriday = 7;
    }
    target = target.add(Duration(days: daysUntilFriday));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel',
        'Prayer Notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      ),
    );

    await _plugin.zonedSchedule(
      NotificationIds.jumuahMubarak,
      '✨ ${_str(locale, 'jumuah')} ✨',
      '',
      target,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  String _buildPayload(PrayerType prayerType) {
    final nonce = DateTime.now().millisecondsSinceEpoch;
    return 'play_full_adhan:${prayerType.name}|$nonce';
  }

  static const Map<String, Map<PrayerType, String>> _localizedPrayerNames = {
    'en': {PrayerType.fajr: 'Fajr', PrayerType.sunrise: 'Sunrise', PrayerType.dhuhr: 'Dhuhr', PrayerType.asr: 'Asr', PrayerType.maghrib: 'Maghrib', PrayerType.isha: 'Isha'},
    'tr': {PrayerType.fajr: 'Sabah', PrayerType.sunrise: 'Güneş', PrayerType.dhuhr: 'Öğle', PrayerType.asr: 'İkindi', PrayerType.maghrib: 'Akşam', PrayerType.isha: 'Yatsı'},
    'ar': {PrayerType.fajr: 'الفجر', PrayerType.sunrise: 'الشروق', PrayerType.dhuhr: 'الظهر', PrayerType.asr: 'العصر', PrayerType.maghrib: 'المغرب', PrayerType.isha: 'العشاء'},
    'ur': {PrayerType.fajr: 'فجر', PrayerType.sunrise: 'طلوع آفتاب', PrayerType.dhuhr: 'ظہر', PrayerType.asr: 'عصر', PrayerType.maghrib: 'مغرب', PrayerType.isha: 'عشاء'},
    'id': {PrayerType.fajr: 'Subuh', PrayerType.sunrise: 'Terbit', PrayerType.dhuhr: 'Dzuhur', PrayerType.asr: 'Ashar', PrayerType.maghrib: 'Maghrib', PrayerType.isha: 'Isya'},
    'fr': {PrayerType.fajr: 'Fajr', PrayerType.sunrise: 'Chourouk', PrayerType.dhuhr: 'Dohr', PrayerType.asr: 'Asr', PrayerType.maghrib: 'Maghrib', PrayerType.isha: 'Isha'},
    'fa': {PrayerType.fajr: 'فجر', PrayerType.sunrise: 'طلوع آفتاب', PrayerType.dhuhr: 'ظهر', PrayerType.asr: 'عصر', PrayerType.maghrib: 'مغرب', PrayerType.isha: 'عشاء'},
    'ja': {PrayerType.fajr: 'ファジュル', PrayerType.sunrise: '日の出', PrayerType.dhuhr: 'ドゥフル', PrayerType.asr: 'アスル', PrayerType.maghrib: 'マグリブ', PrayerType.isha: 'イシャー'},
  };

  static const Map<String, Map<String, String>> _specialNames = {
    'en': {'jumuah': 'Jumu\'ah', 'iftar': 'Iftar', 'suhoor': 'Suhoor'},
    'tr': {'jumuah': 'Cuma', 'iftar': 'İftar', 'suhoor': 'Sahur'},
    'ar': {'jumuah': 'الجمعة', 'iftar': 'الإفطار', 'suhoor': 'السحور'},
    'ur': {'jumuah': 'جمعہ', 'iftar': 'افطار', 'suhoor': 'سحری'},
    'id': {'jumuah': 'Jumat', 'iftar': 'Buka Puasa', 'suhoor': 'Sahur'},
    'fr': {'jumuah': 'Joumou\'a', 'iftar': 'Iftar', 'suhoor': 'Souhour'},
    'fa': {'jumuah': 'جمعه', 'iftar': 'افطار', 'suhoor': 'سحر'},
    'ja': {'jumuah': 'ジュムア', 'iftar': 'イフタール', 'suhoor': 'スフール'},
  };

  String _localizedNotificationPrayerName({
    required PrayerType prayerType,
    required DateTime prayerTime,
    required Map<PrayerType, String> names,
    required bool isRamadan,
    required String locale,
  }) {
    final specials = _specialNames[locale] ?? _specialNames['en']!;
    if (prayerType == PrayerType.dhuhr && prayerTime.weekday == DateTime.friday) {
      return specials['jumuah'] ?? 'Jumu\'ah';
    }
    if (isRamadan && prayerType == PrayerType.maghrib) {
      return specials['iftar'] ?? 'Iftar';
    }
    if (isRamadan && prayerType == PrayerType.fajr) {
      return specials['suhoor'] ?? 'Suhoor';
    }
    return names[prayerType] ?? prayerType.name;
  }

  static String? _parsePrayerNameFromPayload(String? payload) {
    if (payload == null || !payload.startsWith('play_full_adhan:')) {
      return null;
    }
    final encoded = payload.substring('play_full_adhan:'.length);
    return encoded.split('|').first;
  }

  static String? takePendingPrayerFromLaunch() {
    final value = _pendingPrayerFromLaunch;
    _pendingPrayerFromLaunch = null;
    return value;
  }

  Future<String?> consumeLaunchPrayerIfAny() async {
    final storedPayload = await _takeStoredTapPayload();
    if (storedPayload != null && storedPayload.isNotEmpty) {
      if (_lastConsumedPayload != storedPayload) {
        final storedPrayer = _parsePrayerNameFromPayload(storedPayload);
        if (storedPrayer != null) {
          _lastConsumedPayload = storedPayload;
          debugPrint(
            '[Notifications] consumeLaunchPrayer stored payload=$storedPayload '
            'prayer=$storedPrayer',
          );
          return storedPrayer;
        }
      }
    }

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final didLaunch = launchDetails?.didNotificationLaunchApp ?? false;
    final payload = launchDetails?.notificationResponse?.payload;
    debugPrint(
      '[Notifications] consumeLaunchPrayer didLaunch=$didLaunch payload=$payload',
    );
    if (payload == null || payload.isEmpty) {
      return null;
    }
    if (_lastConsumedPayload == payload) {
      return null;
    }
    final prayer = _parsePrayerNameFromPayload(payload);
    if (prayer == null) {
      return null;
    }
    _lastConsumedPayload = payload;
    debugPrint(
      '[Notifications] consumeLaunchPrayer payload=$payload prayer=$prayer',
    );
    return prayer;
  }

  static Future<void> _storeTapPayload(String? payload) async {
    if (payload == null || payload.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingTapPayloadKey, payload);
  }

  static Future<String?> _takeStoredTapPayload() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_pendingTapPayloadKey);
    if (payload == null || payload.isEmpty) {
      return null;
    }
    await prefs.remove(_pendingTapPayloadKey);
    return payload;
  }
}

class _HijriDate {
  const _HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;
}

_HijriDate _gregorianToHijri(DateTime g) {
  final a = ((14 - g.month) / 12).floor();
  final y = g.year + 4800 - a;
  final m = g.month + 12 * a - 3;
  final jdn =
      g.day +
      ((153 * m + 2) / 5).floor() +
      365 * y +
      (y / 4).floor() -
      (y / 100).floor() +
      (y / 400).floor() -
      32045;

  final l = jdn - 1948440 + 10632;
  final n = ((l - 1) / 10631).floor();
  final l1 = l - 10631 * n + 354;
  final j =
      (((10985 - l1) / 5316).floor()) * (((50 * l1) / 17719).floor()) +
      ((l1 / 5670).floor()) * (((43 * l1) / 15238).floor());
  final l2 =
      l1 -
      (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
      ((j / 16).floor()) * (((15238 * j) / 43).floor()) +
      29;
  final month = (24 * l2 / 709).floor();
  final day = l2 - (709 * month / 24).floor();
  final year = 30 * n + j - 30;
  return _HijriDate(year: year, month: month, day: day);
}

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService._storeTapPayload(response.payload);
}
