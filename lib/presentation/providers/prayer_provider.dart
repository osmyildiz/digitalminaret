import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/enums/prayer_type.dart';
import '../../data/models/location_model.dart';
import '../../data/models/prayer_times_model.dart';
import '../../data/repositories/prayer_repository.dart';
import '../../data/services/widget_service.dart';

class PrayerProvider extends ChangeNotifier {
  PrayerProvider({
    required PrayerRepository prayerRepository,
    WidgetService? widgetService,
  }) : _prayerRepository = prayerRepository,
       _widgetService = widgetService ?? WidgetService();

  final PrayerRepository _prayerRepository;
  final WidgetService _widgetService;

  PrayerTimesModel? _prayerTimes;
  PrayerType? _nextPrayer;
  Duration? _timeUntilNext;
  StreamSubscription<Duration>? _countdownSubscription;

  PrayerTimesModel? get prayerTimes => _prayerTimes;
  PrayerType? get nextPrayer => _nextPrayer;
  Duration? get timeUntilNext => _timeUntilNext;

  String _locale = 'en';

  void setLocale(String locale) {
    _locale = locale;
  }

  Future<void> loadPrayerTimes() async {
    _prayerTimes = await _prayerRepository.getTodayPrayerTimes();
    _nextPrayer = _prayerRepository.getCurrentOrNextPrayer();
    final times = _prayerTimes;
    if (times != null) {
      try {
        await _widgetService.updateWidget(times, locale: _locale);
      } catch (error) {
        // Widget update must not block core app flow.
        debugPrint('[PrayerProvider] widget update skipped: $error');
      }
    }
    notifyListeners();
  }

  void startCountdown() {
    _countdownSubscription?.cancel();
    _countdownSubscription = _prayerRepository.getTimeUntilNextPrayer().listen((
      duration,
    ) {
      _timeUntilNext = duration;
      _nextPrayer = _prayerRepository.getCurrentOrNextPrayer();
      notifyListeners();
    });
  }

  Future<void> refreshLocation() async {
    await loadPrayerTimes();
  }

  Future<void> recalculateForLocation(LocationModel location) async {
    await _prayerRepository.calculateAndCachePrayerTimes(location);
    await loadPrayerTimes();
  }

  @override
  void dispose() {
    _countdownSubscription?.cancel();
    super.dispose();
  }
}
