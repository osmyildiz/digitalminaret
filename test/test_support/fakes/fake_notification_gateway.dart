import 'package:digitalminaret/core/scheduling/notification_scheduler.dart';

class ScheduledCall {
  ScheduledCall({
    required this.id,
    required this.scheduledTime,
    required this.prayerType,
    required this.mode,
  });

  final int id;
  final DateTime scheduledTime;
  final SchedulerPrayerType prayerType;
  final SchedulerAlertMode mode;
}

class FakeNotificationGateway implements NotificationGateway {
  int cancelAllCount = 0;
  final List<ScheduledCall> scheduled = <ScheduledCall>[];

  @override
  Future<void> cancelAll() async {
    cancelAllCount += 1;
    scheduled.clear();
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime scheduledTime,
    required SchedulerPrayerType prayerType,
    required SchedulerAlertMode mode,
  }) async {
    scheduled.add(
      ScheduledCall(
        id: id,
        scheduledTime: scheduledTime,
        prayerType: prayerType,
        mode: mode,
      ),
    );
  }
}
