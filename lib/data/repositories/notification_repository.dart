import '../models/prayer_times_model.dart';
import '../models/settings_model.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  const NotificationRepository({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;

  final NotificationService _notificationService;

  Future<void> initialize() {
    return _notificationService.initialize();
  }

  Future<void> scheduleAllPrayerNotifications(
    PrayerTimesModel prayerTimes,
    SettingsModel settings,
  ) {
    return _notificationService.scheduleAllPrayerNotifications(
      prayerTimes,
      settings,
    );
  }

  Future<void> cancelAllNotifications() {
    return _notificationService.cancelAllNotifications();
  }
}
