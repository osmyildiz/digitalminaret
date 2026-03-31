import '../time/date_time_provider.dart';

enum SchedulerPrayerType { fajr, sunrise, dhuhr, asr, maghrib, isha }
enum SchedulerAlertMode { off, silent, vibrate, sound }

class SchedulerPrayerDayTimes {
  SchedulerPrayerDayTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  Map<SchedulerPrayerType, DateTime> asMap() => {
    SchedulerPrayerType.fajr: fajr,
    SchedulerPrayerType.sunrise: sunrise,
    SchedulerPrayerType.dhuhr: dhuhr,
    SchedulerPrayerType.asr: asr,
    SchedulerPrayerType.maghrib: maghrib,
    SchedulerPrayerType.isha: isha,
  };
}

class SchedulerSettings {
  const SchedulerSettings({
    required this.notificationsEnabled,
    required this.alertModes,
    this.nextPrayerOnly = false,
  });

  final bool notificationsEnabled;
  final Map<SchedulerPrayerType, SchedulerAlertMode> alertModes;
  final bool nextPrayerOnly;
}

abstract class NotificationGateway {
  Future<void> cancelAll();

  Future<void> schedule({
    required int id,
    required DateTime scheduledTime,
    required SchedulerPrayerType prayerType,
    required SchedulerAlertMode mode,
  });
}

class NotificationScheduler {
  NotificationScheduler({
    required NotificationGateway gateway,
    required DateTimeProvider dateTimeProvider,
  }) : _gateway = gateway,
       _dateTimeProvider = dateTimeProvider;

  final NotificationGateway _gateway;
  final DateTimeProvider _dateTimeProvider;

  Future<void> sync({
    required SchedulerPrayerDayTimes dayTimes,
    required SchedulerSettings settings,
  }) async {
    await _gateway.cancelAll();

    if (!settings.notificationsEnabled) {
      return;
    }

    final now = _dateTimeProvider.now();
    final enabledFuturePrayers = dayTimes.asMap().entries
        .where((entry) {
          final mode = settings.alertModes[entry.key] ?? SchedulerAlertMode.off;
          return mode != SchedulerAlertMode.off;
        })
        .where((entry) => entry.value.isAfter(now))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final effective = settings.nextPrayerOnly && enabledFuturePrayers.isNotEmpty
        ? <MapEntry<SchedulerPrayerType, DateTime>>[enabledFuturePrayers.first]
        : enabledFuturePrayers;

    for (final entry in effective) {
      await _gateway.schedule(
        id: _notificationId(entry.key),
        scheduledTime: entry.value,
        prayerType: entry.key,
        mode: settings.alertModes[entry.key] ?? SchedulerAlertMode.off,
      );
    }
  }

  int _notificationId(SchedulerPrayerType prayerType) {
    switch (prayerType) {
      case SchedulerPrayerType.fajr:
        return 1;
      case SchedulerPrayerType.sunrise:
        return 2;
      case SchedulerPrayerType.dhuhr:
        return 3;
      case SchedulerPrayerType.asr:
        return 4;
      case SchedulerPrayerType.maghrib:
        return 5;
      case SchedulerPrayerType.isha:
        return 6;
    }
  }
}
