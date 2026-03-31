import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'background/background_tasks.dart';
import 'core/utils/logger.dart';
import 'data/services/donation_service.dart';
import 'data/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  final supportsWorkmanager =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  if (supportsWorkmanager) {
    await Workmanager().initialize(callbackDispatcher);
    try {
      await Workmanager().registerPeriodicTask(
        dailyPrayerUpdateTask,
        dailyPrayerUpdateTask,
        frequency: const Duration(hours: 24),
        initialDelay: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        constraints: Constraints(networkType: NetworkType.notRequired),
      );
    } catch (error) {
      AppLogger.debug('Workmanager register failed: $error');
    }
  }
  try {
    // Must be ready before first frame so notification-tap payload is not missed.
    await NotificationService().initialize();
  } catch (error) {
    AppLogger.debug('Notification bootstrap failed: $error');
  }

  runApp(const DigitalMinaretApp());

  // Keep RevenueCat async to avoid slowing startup.
  Future<void>(() async {
    try {
      await DonationService().initialize();
    } catch (error) {
      AppLogger.debug('Donation bootstrap failed: $error');
    }
  });
}
