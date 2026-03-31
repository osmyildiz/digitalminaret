import '../enums/calculation_method.dart';

class AppConstants {
  static const CalculationMethod defaultCalculationMethod =
      CalculationMethod.isna;

  static const String locationStorageKey = 'location';
  static const String settingsStorageKey = 'settings';
  static const String prayerTimesStorageKey = 'prayer_times';
  static const String appOpenCountKey = 'app_open_count';
  static const String hasRatedKey = 'has_rated';
  static const String timezoneOffsetMinutesKey = 'timezone_offset_minutes';

  static const int ratePromptFirstOpen = 11;
  static const int ratePromptInterval = 11;

  static bool shouldShowRatePrompt({
    required int appOpenCount,
    required bool hasRated,
  }) {
    if (hasRated || appOpenCount < ratePromptFirstOpen) {
      return false;
    }
    return (appOpenCount - ratePromptFirstOpen) % ratePromptInterval == 0;
  }

  static const String feedbackEmail = 'osmyildiz1@gmail.com';
  static const String privacyNotesUrl = 'https://example.com/privacy';
  static const String iosStoreRatingUrl =
      'https://apps.apple.com/us/app/digital-minaret-prayer/id6759538454';
  static const String androidStoreRatingUrl =
      'https://play.google.com/store/apps/details?id=com.osmyildiz.digitalminaret';

  // RevenueCat / In-App Purchase
  static const String tipSmallProductId = 'tip_small';
  static const String tipMediumProductId = 'tip_medium';
  static const String tipLargeProductId = 'tip_large';

  // RevenueCat public SDK key (iOS)
  static const String revenueCatAppleApiKey = 'appl_NJIQQXkNIBesVsmdLXiWotdfoNA';
  static const String revenueCatGoogleApiKey = String.fromEnvironment(
    'RC_GOOGLE_API_KEY',
    defaultValue: 'goog_mnilHnEEJdcbPyIErYCONzNvffW',
  );
}
