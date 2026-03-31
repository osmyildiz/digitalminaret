import '../../data/models/prayer_times_model.dart';
import '../../data/models/settings_model.dart';
import '../../data/repositories/notification_repository.dart';

class ScheduleNotificationsUseCase {
  const ScheduleNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> call(PrayerTimesModel prayerTimes, SettingsModel settings) {
    return _repository.scheduleAllPrayerNotifications(prayerTimes, settings);
  }
}
