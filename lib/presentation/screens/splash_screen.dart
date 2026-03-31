import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/locale_defaults.dart';
import '../../core/utils/logger.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import '../providers/location_provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final storageService = StorageService();
    final settingsProvider = context.read<SettingsProvider>();
    final locationProvider = context.read<LocationProvider>();
    final prayerProvider = context.read<PrayerProvider>();

    try {
      await storageService.incrementAppOpenCount();

      final isFirstLaunch = !await storageService.hasSettingsBeenSaved();
      await settingsProvider.loadSettings();

      if (isFirstLaunch) {
        final platformLocale = ui.PlatformDispatcher.instance.locale;
        final appLocale = LocaleDefaults.resolveAppLocale(platformLocale);
        final method = LocaleDefaults.resolveCalculationMethod(platformLocale);
        await settingsProvider.saveSettings(
          settingsProvider.settings.copyWith(
            locale: appLocale,
            calculationMethod: method,
          ),
        );
      }

      await locationProvider.loadLocation();
      if (locationProvider.location != null) {
        prayerProvider.setLocale(settingsProvider.settings.locale);
        await prayerProvider.loadPrayerTimes();
        prayerProvider.startCountdown();
        final times = prayerProvider.prayerTimes;
        if (times != null) {
          await NotificationService().scheduleAllPrayerNotifications(
            times,
            settingsProvider.settings,
          );
        }
        // Check if user has moved - non-blocking, runs after navigation
        _refreshLocationInBackground(
          locationProvider,
          prayerProvider,
          settingsProvider,
        );
      }
    } catch (error) {
      AppLogger.debug('Bootstrap error: $error');
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => locationProvider.location == null
            ? const OnboardingScreen()
            : const HomeScreen(),
      ),
    );
  }

  void _refreshLocationInBackground(
    LocationProvider locationProvider,
    PrayerProvider prayerProvider,
    SettingsProvider settingsProvider,
  ) {
    // Fire-and-forget: don't block app startup
    locationProvider.refreshIfMoved().then((moved) async {
      if (!moved || !mounted) return;
      await prayerProvider.recalculateForLocation(locationProvider.location!);
      prayerProvider.startCountdown();
      final times = prayerProvider.prayerTimes;
      if (times != null) {
        await NotificationService().scheduleAllPrayerNotifications(
          times,
          settingsProvider.settings,
        );
      }
    }).catchError((_) {
      // Silently ignore
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF02030A),
              Color(0xFF071330),
              Color(0xFF02030A),
            ],
            stops: <double>[0.0, 0.55, 1.0],
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD98F)),
        ),
      ),
    );
  }
}
