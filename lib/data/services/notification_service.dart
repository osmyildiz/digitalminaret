import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/adhan_playback_bus.dart';
import '../../core/constants/notification_ids.dart';
import '../../core/enums/prayer_alert_mode.dart';
import '../../core/enums/prayer_type.dart';
import '../models/prayer_times_model.dart';
import '../models/settings_model.dart';

class NotificationService {
  NotificationService._internal({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

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

  Future<void> scheduleAllPrayerNotifications(
    PrayerTimesModel times,
    SettingsModel settings,
  ) async {
    if (!settings.notificationsEnabled) {
      await cancelAllNotifications();
      return;
    }

    final locale = settings.locale;
    final names = _localizedPrayerNames[locale] ?? _localizedPrayerNames['en']!;

    final map = <PrayerType, DateTime>{
      PrayerType.fajr: times.fajr,
      PrayerType.sunrise: times.sunrise,
      PrayerType.dhuhr: times.dhuhr,
      PrayerType.asr: times.asr,
      PrayerType.maghrib: times.maghrib,
      PrayerType.isha: times.isha,
    };
    final hijri = _gregorianToHijri(times.date);
    final isRamadan = hijri.month == 9;

    for (final entry in map.entries) {
      final mode =
          settings.prayerAlertModes[entry.key] ??
          ((settings.enabledPrayers[entry.key] ?? true)
              ? PrayerAlertMode.sound
              : PrayerAlertMode.off);
      if (mode != PrayerAlertMode.off) {
        final prayerName = _localizedNotificationPrayerName(
          prayerType: entry.key,
          prayerTime: entry.value,
          names: names,
          isRamadan: isRamadan,
          locale: locale,
        );
        await scheduleSingleNotification(
          id: _notificationReminderIdFor(entry.key),
          scheduledTime: entry.value.subtract(const Duration(minutes: 15)),
          title: _str(locale, 'in_minutes', prayer: prayerName),
          body: _str(locale, 'prepare'),
          alertMode: mode,
          prayerType: entry.key,
          playAdhanOnTap: false,
        );
        await scheduleSingleNotification(
          id: _notificationIdFor(entry.key),
          scheduledTime: entry.value,
          title: _str(locale, 'time', prayer: prayerName),
          body: _str(locale, 'started'),
          alertMode: mode,
          prayerType: entry.key,
          playAdhanOnTap: true,
        );

        if (_shouldScheduleTashreeq(hijri: hijri, prayerType: entry.key)) {
          await scheduleSingleNotification(
            id: _notificationTashreeqIdFor(entry.key),
            scheduledTime: entry.value.add(const Duration(minutes: 10)),
            title: '✨ ${_str(locale, 'tashreeq_title')} ✨',
            body: _str(locale, 'tashreeq_body'),
            alertMode: mode,
            prayerType: entry.key,
            playAdhanOnTap: false,
          );
        }
      }
    }

    await _scheduleJumuahMubarakNotification(locale);
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

  Future<void> cancelAllNotifications() {
    return _plugin.cancelAll();
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
  };

  static const Map<String, Map<String, String>> _specialNames = {
    'en': {'jumuah': 'Jumu\'ah', 'iftar': 'Iftar', 'suhoor': 'Suhoor'},
    'tr': {'jumuah': 'Cuma', 'iftar': 'İftar', 'suhoor': 'Sahur'},
    'ar': {'jumuah': 'الجمعة', 'iftar': 'الإفطار', 'suhoor': 'السحور'},
    'ur': {'jumuah': 'جمعہ', 'iftar': 'افطار', 'suhoor': 'سحری'},
    'id': {'jumuah': 'Jumat', 'iftar': 'Buka Puasa', 'suhoor': 'Sahur'},
    'fr': {'jumuah': 'Joumou\'a', 'iftar': 'Iftar', 'suhoor': 'Souhour'},
    'fa': {'jumuah': 'جمعه', 'iftar': 'افطار', 'suhoor': 'سحر'},
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
