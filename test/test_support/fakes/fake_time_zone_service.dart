class FakeTimeZoneService {
  FakeTimeZoneService(this.currentZone);

  String currentZone;

  DateTime toLocal(DateTime utc) {
    if (currentZone == 'Europe/Istanbul') {
      return utc.toUtc().add(const Duration(hours: 3));
    }
    if (currentZone == 'America/New_York') {
      return utc.toUtc().subtract(const Duration(hours: 5));
    }
    return utc.toLocal();
  }
}
