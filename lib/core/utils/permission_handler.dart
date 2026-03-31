import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

class PermissionHandler {
  const PermissionHandler();

  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> requestNotificationPermission(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final androidResult = await android?.requestNotificationsPermission();
    final iosResult = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return (androidResult ?? true) && (iosResult ?? true);
  }
}
