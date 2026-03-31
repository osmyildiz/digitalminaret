abstract class DateTimeProvider {
  DateTime now();
}

class SystemDateTimeProvider implements DateTimeProvider {
  const SystemDateTimeProvider();

  @override
  DateTime now() => DateTime.now();
}
