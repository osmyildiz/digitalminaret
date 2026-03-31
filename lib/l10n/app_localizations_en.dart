// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Digital Minaret';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerJumuah => 'Jumuah';

  @override
  String get prayerIftar => 'Iftar';

  @override
  String get prayerSuhoor => 'Suhoor';

  @override
  String get arabicFajr => 'فجر';

  @override
  String get arabicSunrise => 'شروق';

  @override
  String get arabicDhuhr => 'ظهر';

  @override
  String get arabicAsr => 'عصر';

  @override
  String get arabicMaghrib => 'مغرب';

  @override
  String get arabicIsha => 'عشاء';

  @override
  String get arabicJumuah => 'جمعة';

  @override
  String get suhoorEnds => 'SUHOOR ENDS';

  @override
  String get iftarTime => 'IFTAR TIME';

  @override
  String get unknown => 'Unknown';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeSubtitle =>
      'Set location, calculation method, and madhab to start with accurate prayer times.';

  @override
  String get continueButton => 'Continue';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get notNow => 'Not Now';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get download => 'Download';

  @override
  String get retry => 'Retry';

  @override
  String get settings => 'Settings';

  @override
  String get stepLocation => '1. Location';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get enterLocation => 'Enter Location';

  @override
  String get searchLocation => 'Search Location';

  @override
  String get cityOrAddress => 'City or address';

  @override
  String get noLocationSelected => 'No location selected';

  @override
  String locationSetTo(String cityName) {
    return 'Location set to $cityName. Prayer times refreshed.';
  }

  @override
  String get locationUpdated => 'Location updated and prayer times refreshed.';

  @override
  String get unableToGetLocation =>
      'Unable to get location. Try manual search.';

  @override
  String get stepCalculationMethod => '2. Calculation Method';

  @override
  String get stepAsrMadhab => '3. Asr Madhab';

  @override
  String get stepFullAdhanPack => '4. Full Adhan Pack';

  @override
  String get adhanPackNote =>
      'Notification adhan stays fixed at 30 seconds. This selection is used for full adhan when you tap the notification.';

  @override
  String get methodIsna => 'North America (ISNA)';

  @override
  String get methodMuslimWorldLeague => 'Muslim World League';

  @override
  String get methodTurkeyDiyanet => 'Türkiye Diyanet';

  @override
  String get methodEgyptian => 'Egyptian';

  @override
  String get methodKarachi => 'Karachi (UISC)';

  @override
  String get methodUmmAlQura => 'Umm al-Qura (Makkah)';

  @override
  String get methodDubai => 'Dubai (Gulf Region)';

  @override
  String get methodSingapore => 'Singapore / SE Asia';

  @override
  String get methodTehran => 'Tehran (Iran)';

  @override
  String get madhabNonHanafi => 'Non-Hanafi';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get asrMadhab => 'Asr Madhab';

  @override
  String get location => 'Location';

  @override
  String get calculation => 'Calculation';

  @override
  String get notifications => 'Notifications';

  @override
  String get adhanAudio => 'Adhan Audio';

  @override
  String get supportAndTrust => 'Support & Trust';

  @override
  String get permissionNeeded => 'Permission Needed';

  @override
  String get pleaseAllowNotifications =>
      'Please allow notifications in iPhone Settings.';

  @override
  String get fullAdhanOnNotificationTap => 'Full adhan on notification tap';

  @override
  String get playDuaAfterAdhan => 'Play dua after adhan';

  @override
  String adhanPackLabel(String packName) {
    return 'Adhan Pack: $packName';
  }

  @override
  String get adhanPacks => 'Adhan Packs';

  @override
  String get downloadAdhanPack => 'Download Adhan Pack';

  @override
  String adhanPackDownloadPrompt(String packName) {
    return '$packName will be downloaded to your device. Continue?';
  }

  @override
  String get downloadingAdhanPack => 'Downloading adhan pack...';

  @override
  String downloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String packDownloaded(String packName) {
    return '$packName downloaded.';
  }

  @override
  String get donate => 'Donate';

  @override
  String get donateSubtitle => 'Support development if you wish.';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get sendFeedbackSubtitle => 'Open a quick form';

  @override
  String get widgetSetup => 'Widget Setup';

  @override
  String get widgetSetupSubtitle =>
      'How to add and refresh the live home screen widget.';

  @override
  String get privacyNotes => 'Privacy Notes';

  @override
  String get privacyNotesSubtitle => 'Read how data is handled on-device.';

  @override
  String get thankYouForUsing => 'Thank you for using Digital Minaret.';

  @override
  String get appAlwaysFree =>
      'This app will always stay ad-free and free to use.';

  @override
  String get rateDigitalMinaret => 'Rate Digital Minaret';

  @override
  String get ratePromptMessage =>
      'Are you enjoying the spiritual journey? Your feedback helps us illuminate the path.';

  @override
  String get couldNotOpenLink => 'Could not open link on this device.';

  @override
  String couldNotPlayPreview(String error) {
    return 'Could not play adhan preview: $error';
  }

  @override
  String notificationsCouldNotBeScheduled(String error) {
    return 'Notifications could not be fully scheduled: $error';
  }

  @override
  String couldNotContinue(String error) {
    return 'Could not continue. Please try again. ($error)';
  }

  @override
  String get hadithOfTheDay => 'Hadith of the Day';

  @override
  String get ramadanDua => 'Ramadan Dua';

  @override
  String get verseFromQuran => 'Verse from the Quran';

  @override
  String get hadithBody =>
      'The month of Ramadan has come to you, a blessed month which Allah has obligated you to fast. (Nasa\'i)';

  @override
  String get duaBody =>
      'O Allah, I ask You for Your love, and the love of those who love You, and the deeds that bring me closer to Your love.';

  @override
  String get verseBody =>
      'O you who have believed, decreed upon you is fasting as it was decreed upon those before you that you may become righteous. (Al-Baqarah 2:183)';

  @override
  String get supportTheApp => 'Support the App';

  @override
  String get donateDescription =>
      'This app is free and ad-free. If you want, you can support development with a one-time tip.';

  @override
  String get purchaseDidNotComplete => 'Purchase did not complete.';

  @override
  String get thankYou => 'Thank You';

  @override
  String get thankYouDonateMessage =>
      'Your support means a lot. This helps keep the app free and ad-free.';

  @override
  String get smallTip => 'Small Tip';

  @override
  String get mediumTip => 'Medium Tip';

  @override
  String get largeTip => 'Large Tip';

  @override
  String get donationOptionsUnavailable =>
      'Donation options are not available yet.';

  @override
  String get donationOptionsSetup =>
      'Add RevenueCat keys and store products (tip_small, tip_medium, tip_large), then retry.';

  @override
  String get feedbackSubject => 'Feedback for Digital Minaret';

  @override
  String get mailCouldNotBeOpened => 'Mail app could not be opened.';

  @override
  String get openMailApp => 'Open Mail App';

  @override
  String get subject => 'Subject';

  @override
  String get yourFeedback => 'Your feedback';

  @override
  String get feedbackHint =>
      'This opens your default mail app with prefilled fields.';

  @override
  String get privacyNoAccountRequired => 'No account required';

  @override
  String get privacyNoAccountBody =>
      'You can use the app without creating an account or sharing personal profile data.';

  @override
  String get privacyLocationOnDevice => 'Location stays on device';

  @override
  String get privacyLocationBody =>
      'Location is used only to calculate prayer times and is stored locally on your phone.';

  @override
  String get privacyNoAds => 'No ads, no trackers';

  @override
  String get privacyNoAdsBody =>
      'The app has no advertising SDK and no analytics tracking by default.';

  @override
  String get privacyNotificationsLocal => 'Notifications are local';

  @override
  String get privacyNotificationsBody =>
      'Prayer notifications are scheduled and triggered directly on device.';

  @override
  String get privacyFeedbackOptIn => 'Feedback is opt-in';

  @override
  String get privacyFeedbackBody =>
      'If you tap feedback, your default mail app opens. Nothing is sent automatically.';

  @override
  String get widgetSetupTitle => 'Widget Setup';

  @override
  String get widgetLiveTitle => 'Live Widget';

  @override
  String get widgetLiveBody =>
      'The widget shows current prayer, next prayer and remaining time. Data updates when app calculates/syncs prayer times, and timeline refreshes each minute.';

  @override
  String get widgetIosTitle => 'iOS';

  @override
  String get widgetIosBody =>
      'Long press Home Screen > + > Digital Minaret > choose size > Add Widget.\nIf it does not appear after an update: remove widget, open app once, then add again.';

  @override
  String get widgetAndroidTitle => 'Android';

  @override
  String get widgetAndroidBody =>
      'Long press Home Screen > Widgets > Digital Minaret.\nIf stale: remove/re-add widget and open app once to push fresh times.';

  @override
  String get widgetTypographyTitle => 'Typography';

  @override
  String get widgetTypographyBody =>
      'Widget typography is aligned with app style (Cinzel + Manrope) on both iOS and Android.';

  @override
  String get language => 'Language';

  @override
  String get hijriMuharram => 'Muharram';

  @override
  String get hijriSafar => 'Safar';

  @override
  String get hijriRabiAwwal => 'Rabi al-Awwal';

  @override
  String get hijriRabiThani => 'Rabi al-Thani';

  @override
  String get hijriJumadaAwwal => 'Jumada al-Awwal';

  @override
  String get hijriJumadaThani => 'Jumada al-Thani';

  @override
  String get hijriRajab => 'Rajab';

  @override
  String get hijriShaaban => 'Shaaban';

  @override
  String get hijriRamadan => 'Ramadan';

  @override
  String get hijriShawwal => 'Shawwal';

  @override
  String get hijriDhuAlQadah => 'Dhu al-Qadah';

  @override
  String get hijriDhuAlHijjah => 'Dhu al-Hijjah';

  @override
  String hijriDateFormat(String day, String month, String year) {
    return '$day $month $year AH';
  }

  @override
  String get eidAlFitr => 'Eid al-Fitr Prayer';

  @override
  String get eidAlAdha => 'Eid al-Adha Prayer';

  @override
  String get qibla => 'Qibla';

  @override
  String get towardsTheQibla => 'TOWARDS THE QIBLA';

  @override
  String get compassNotAvailable =>
      'Compass sensor not available on this device.';

  @override
  String get locationRequiredForQibla =>
      'Location is required to determine Qibla direction.';
}
