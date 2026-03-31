import 'package:flutter/foundation.dart';

class AppLogger {
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[DigitalMinaret] $message');
    }
  }
}
