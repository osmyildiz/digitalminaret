import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'core/enums/prayer_type.dart';
import 'core/utils/adhan_playback_bus.dart';
import 'data/repositories/location_repository.dart';
import 'data/repositories/prayer_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/adhan_service.dart';
import 'data/services/audio_service.dart';
import 'data/services/location_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/prayer_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/theme/app_theme.dart';

class DigitalMinaretApp extends StatelessWidget {
  const DigitalMinaretApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();

    final prayerRepository = PrayerRepository(
      storageService: storageService,
      adhanService: AdhanService(),
    );

    final locationRepository = LocationRepository(
      locationService: LocationService(),
      storageService: storageService,
    );

    final settingsRepository = SettingsRepository(
      storageService: storageService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) =>
              SettingsProvider(settingsRepository: settingsRepository),
        ),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) =>
              LocationProvider(locationRepository: locationRepository),
        ),
        ChangeNotifierProvider<PrayerProvider>(
          create: (_) => PrayerProvider(prayerRepository: prayerRepository),
        ),
      ],
      child: _NotificationAudioGate(
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            return MaterialApp(
              title: 'Digital Minaret',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              locale: Locale(settingsProvider.settings.locale),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationAudioGate extends StatefulWidget {
  const _NotificationAudioGate({required this.child});

  final Widget child;

  @override
  State<_NotificationAudioGate> createState() => _NotificationAudioGateState();
}

class _NotificationAudioGateState extends State<_NotificationAudioGate>
    with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();
  bool _timezoneRefreshInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdhanPlaybackBus.playFullAdhanPrayer.addListener(_playFromNotification);
    Future<void>.delayed(const Duration(milliseconds: 500), () async {
      await _refreshOnTimezoneOffsetChange();
      await _checkAndHandleNotificationPayload();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AdhanPlaybackBus.playFullAdhanPrayer.removeListener(_playFromNotification);
    _audioService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future<void>.delayed(const Duration(milliseconds: 350), () async {
        await _refreshOnTimezoneOffsetChange();
        await _refreshLocationIfMoved();
        await _checkAndHandleNotificationPayload();
      });
    }
  }

  Future<void> _refreshOnTimezoneOffsetChange() async {
    if (_timezoneRefreshInProgress) {
      return;
    }
    _timezoneRefreshInProgress = true;

    try {
      final prayerProvider = context.read<PrayerProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final currentOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
      final lastOffsetMinutes = await _storageService
          .getLastTimezoneOffsetMinutes();

      if (lastOffsetMinutes == null) {
        await _storageService.setLastTimezoneOffsetMinutes(
          currentOffsetMinutes,
        );
        return;
      }

      if (lastOffsetMinutes == currentOffsetMinutes) {
        return;
      }

      await _storageService.setLastTimezoneOffsetMinutes(currentOffsetMinutes);

      final location = await _storageService.getLocation();
      if (location == null) {
        return;
      }

      await prayerProvider.recalculateForLocation(location);
      prayerProvider.startCountdown();

      final times = prayerProvider.prayerTimes;
      if (times != null) {
        await _notificationService.scheduleAllPrayerNotifications(
          times,
          settingsProvider.settings,
        );
      }
      debugPrint(
        '[Timezone] offset changed ($lastOffsetMinutes -> '
        '$currentOffsetMinutes). Prayer times and notifications refreshed.',
      );
    } catch (error) {
      debugPrint('[Timezone] refresh skipped due to error: $error');
    } finally {
      _timezoneRefreshInProgress = false;
    }
  }

  Future<void> _refreshLocationIfMoved() async {
    try {
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.location == null) {
        return;
      }
      final moved = await locationProvider.refreshIfMoved();
      if (!moved || !mounted) {
        return;
      }
      final prayerProvider = context.read<PrayerProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      await prayerProvider.recalculateForLocation(locationProvider.location!);
      prayerProvider.startCountdown();
      final times = prayerProvider.prayerTimes;
      if (times != null) {
        await _notificationService.scheduleAllPrayerNotifications(
          times,
          settingsProvider.settings,
        );
      }
      debugPrint(
        '[Location] moved to ${locationProvider.location!.cityName}. '
        'Prayer times and notifications refreshed.',
      );
    } catch (error) {
      debugPrint('[Location] auto-refresh skipped: $error');
    }
  }

  Future<void> _checkAndHandleNotificationPayload() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final pending = NotificationService.takePendingPrayerFromLaunch();
      final launchPrayer = await _notificationService
          .consumeLaunchPrayerIfAny();
      final prayer = launchPrayer ?? pending;
      if (prayer != null && prayer.isNotEmpty) {
        AdhanPlaybackBus.playFullAdhanPrayer.value = prayer;
        await _playFromNotification();
        return;
      }
      if (attempt < 2) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  Future<void> _playFromNotification() async {
    final prayerName = AdhanPlaybackBus.playFullAdhanPrayer.value;
    if (prayerName == null || prayerName.isEmpty) {
      return;
    }
    AdhanPlaybackBus.playFullAdhanPrayer.value = null;

    final settings = context.read<SettingsProvider>().settings;
    final prayerType = PrayerType.values.firstWhere(
      (p) => p.name == prayerName,
      orElse: () => PrayerType.isha,
    );
    await _audioService.playFullAdhanForPrayer(
      prayerType: prayerType,
      selectedPackId: settings.selectedAdhanPackId,
      playPostAdhanDua: settings.postAdhanDuaEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
