import 'package:digitalminaret/core/time/date_time_provider.dart';

class FakeDateTimeProvider implements DateTimeProvider {
  FakeDateTimeProvider(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void setNow(DateTime value) {
    _now = value;
  }
}
