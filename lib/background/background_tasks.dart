import 'package:flutter/widgets.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:workmanager/workmanager.dart';

import '../data/repositories/notification_repository.dart';
import '../data/repositories/prayer_repository.dart';
import '../data/services/adhan_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/widget_service.dart';
import '../core/utils/logger.dart';

const String dailyPrayerUpdateTask = 'dailyPrayerUpdate';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    tz_data.initializeTimeZones();

    if (task == dailyPrayerUpdateTask) {
      return _runDailyPrayerUpdate();
    }

    return Future<bool>.value(false);
  });
}

Future<bool> _runDailyPrayerUpdate() async {
  try {
    AppLogger.debug('dailyPrayerUpdate task started');
    final storage = StorageService();
    final prayerRepository = PrayerRepository(
      storageService: storage,
      adhanService: AdhanService(),
    );
    final notificationRepository = NotificationRepository(
      notificationService: NotificationService(),
    );
    await notificationRepository.initialize();
    final widgetService = WidgetService();

    final location = await storage.getLocation();
    if (location == null) {
      AppLogger.debug('dailyPrayerUpdate skipped: no location');
      return true;
    }

    await prayerRepository.calculateAndCachePrayerTimes(location);
    final times = await prayerRepository.getTodayPrayerTimes();
    final settings = await storage.getSettings();

    await notificationRepository.scheduleAllPrayerNotifications(times, settings);
    await widgetService.updateWidget(times, locale: settings.locale);

    AppLogger.debug('dailyPrayerUpdate task completed');
    return true;
  } catch (error) {
    AppLogger.debug('dailyPrayerUpdate failed: $error');
    return false;
  }
}
