import '../../data/models/prayer_times_model.dart';
import '../../data/services/widget_service.dart';

class UpdateWidgetUseCase {
  const UpdateWidgetUseCase(this._widgetService);

  final WidgetService _widgetService;

  Future<void> call(PrayerTimesModel prayerTimes, {String locale = 'en'}) {
    return _widgetService.updateWidget(prayerTimes, locale: locale);
  }
}
