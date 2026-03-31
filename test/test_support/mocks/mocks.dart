import 'package:digitalminaret/data/repositories/location_repository.dart';
import 'package:digitalminaret/data/repositories/prayer_repository.dart';
import 'package:digitalminaret/data/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationRepository extends Mock implements LocationRepository {}
class MockPrayerRepository extends Mock implements PrayerRepository {}

class MockNotificationService extends Mock implements NotificationService {}
