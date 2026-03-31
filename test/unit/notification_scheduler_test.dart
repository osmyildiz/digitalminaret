// Guarantees notification scheduling logic without hitting platform plugins.
import 'package:digitalminaret/core/scheduling/notification_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support/fakes/fake_date_time_provider.dart';
import '../test_support/fakes/fake_notification_gateway.dart';

void main() {
  late FakeNotificationGateway gateway;
  late FakeDateTimeProvider clock;
  late NotificationScheduler scheduler;
  late SchedulerPrayerDayTimes tomorrowTimes;

  setUp(() {
    gateway = FakeNotificationGateway();
    clock = FakeDateTimeProvider(DateTime(2026, 2, 15, 12, 0));
    scheduler = NotificationScheduler(gateway: gateway, dateTimeProvider: clock);
    tomorrowTimes = SchedulerPrayerDayTimes(
      fajr: DateTime(2026, 2, 16, 5, 31),
      sunrise: DateTime(2026, 2, 16, 6, 49),
      dhuhr: DateTime(2026, 2, 16, 12, 10),
      asr: DateTime(2026, 2, 16, 15, 47),
      maghrib: DateTime(2026, 2, 16, 17, 30),
      isha: DateTime(2026, 2, 16, 18, 48),
    );
  });

  test('notifications off => cancel only', () async {
    await scheduler.sync(
      dayTimes: tomorrowTimes,
      settings: const SchedulerSettings(
        notificationsEnabled: false,
        alertModes: {},
      ),
    );

    expect(gateway.cancelAllCount, 1);
    expect(gateway.scheduled, isEmpty);
  });

  test('notifications on => schedules enabled prayer modes', () async {
    await scheduler.sync(
      dayTimes: tomorrowTimes,
      settings: const SchedulerSettings(
        notificationsEnabled: true,
        alertModes: {
          SchedulerPrayerType.fajr: SchedulerAlertMode.sound,
          SchedulerPrayerType.sunrise: SchedulerAlertMode.off,
          SchedulerPrayerType.dhuhr: SchedulerAlertMode.silent,
          SchedulerPrayerType.asr: SchedulerAlertMode.vibrate,
          SchedulerPrayerType.maghrib: SchedulerAlertMode.sound,
          SchedulerPrayerType.isha: SchedulerAlertMode.sound,
        },
      ),
    );

    expect(gateway.scheduled.length, 5);
    expect(
      gateway.scheduled.any(
        (c) => c.prayerType == SchedulerPrayerType.sunrise,
      ),
      isFalse,
    );
  });

  test('mode/city/method change simulation cancels old then schedules new', () async {
    await scheduler.sync(
      dayTimes: tomorrowTimes,
      settings: const SchedulerSettings(
        notificationsEnabled: true,
        alertModes: {
          SchedulerPrayerType.fajr: SchedulerAlertMode.sound,
          SchedulerPrayerType.maghrib: SchedulerAlertMode.sound,
        },
      ),
    );

    await scheduler.sync(
      dayTimes: tomorrowTimes,
      settings: const SchedulerSettings(
        notificationsEnabled: true,
        alertModes: {
          SchedulerPrayerType.isha: SchedulerAlertMode.sound,
        },
      ),
    );

    expect(gateway.cancelAllCount, 2);
    expect(gateway.scheduled.length, 1);
    expect(gateway.scheduled.first.prayerType, SchedulerPrayerType.isha);
  });

  test('next-prayer-only mode schedules exactly one item', () async {
    await scheduler.sync(
      dayTimes: tomorrowTimes,
      settings: const SchedulerSettings(
        notificationsEnabled: true,
        nextPrayerOnly: true,
        alertModes: {
          SchedulerPrayerType.fajr: SchedulerAlertMode.sound,
          SchedulerPrayerType.dhuhr: SchedulerAlertMode.sound,
          SchedulerPrayerType.maghrib: SchedulerAlertMode.sound,
        },
      ),
    );

    expect(gateway.scheduled.length, 1);
    expect(gateway.scheduled.first.prayerType, SchedulerPrayerType.fajr);
  });

  test('past prayers on same day are not scheduled', () async {
    final mixedTimes = SchedulerPrayerDayTimes(
      fajr: DateTime(2026, 2, 15, 5, 31),
      sunrise: DateTime(2026, 2, 15, 6, 49),
      dhuhr: DateTime(2026, 2, 15, 12, 10),
      asr: DateTime(2026, 2, 15, 15, 47),
      maghrib: DateTime(2026, 2, 15, 17, 30),
      isha: DateTime(2026, 2, 15, 18, 48),
    );

    await scheduler.sync(
      dayTimes: mixedTimes,
      settings: const SchedulerSettings(
        notificationsEnabled: true,
        alertModes: {
          SchedulerPrayerType.fajr: SchedulerAlertMode.sound,
          SchedulerPrayerType.sunrise: SchedulerAlertMode.sound,
          SchedulerPrayerType.dhuhr: SchedulerAlertMode.sound,
          SchedulerPrayerType.asr: SchedulerAlertMode.sound,
          SchedulerPrayerType.maghrib: SchedulerAlertMode.sound,
          SchedulerPrayerType.isha: SchedulerAlertMode.sound,
        },
      ),
    );

    expect(gateway.scheduled.length, 4);
    expect(gateway.scheduled.first.prayerType, SchedulerPrayerType.dhuhr);
  });
}
