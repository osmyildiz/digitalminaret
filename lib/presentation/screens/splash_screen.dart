import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import '../../core/constants/app_constants.dart';
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

  // Default true so a mid-bootstrap exception sends the user to onboarding
  // rather than Home with a null location.
  bool _showOnboarding = true;

  Future<void> _bootstrap() async {
    final storageService = StorageService();
    final settingsProvider = context.read<SettingsProvider>();
    final locationProvider = context.read<LocationProvider>();
    final prayerProvider = context.read<PrayerProvider>();

    try {
      await storageService.incrementAppOpenCount();

      final isFirstLaunch = !await storageService.hasSettingsBeenSaved();
      final lastSeenOnboarding =
          await storageService.getLastSeenOnboardingVersion();
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
      _showOnboarding = locationProvider.location == null ||
          lastSeenOnboarding < AppConstants.currentOnboardingVersion;
      if (locationProvider.location != null) {
        prayerProvider.setLocale(settingsProvider.settings.locale);
        prayerProvider.setLiveActivityEnabled(
          settingsProvider.settings.liveActivityEnabled,
        );
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
        // Returning users land on Home wrapped in UpgradeAlert — it
        // checks the App Store / Play Store on launch and shows an
        // "update available" dialog when a newer version is published.
        // First-run users (onboarding) already have the latest build.
        builder: (_) => _showOnboarding
            ? const OnboardingScreen()
            : UpgradeAlert(
                upgrader: Upgrader(
                  durationUntilAlertAgain: const Duration(days: 1),
                ),
                dialogStyle: UpgradeDialogStyle.cupertino,
                showReleaseNotes: false,
                showIgnore: false,
                child: const HomeScreen(),
              ),
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
