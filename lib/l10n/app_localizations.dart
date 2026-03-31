import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fa'),
    Locale('fr'),
    Locale('id'),
    Locale('tr'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Minaret'**
  String get appTitle;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @prayerJumuah.
  ///
  /// In en, this message translates to:
  /// **'Jumuah'**
  String get prayerJumuah;

  /// No description provided for @prayerIftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get prayerIftar;

  /// No description provided for @prayerSuhoor.
  ///
  /// In en, this message translates to:
  /// **'Suhoor'**
  String get prayerSuhoor;

  /// No description provided for @arabicFajr.
  ///
  /// In en, this message translates to:
  /// **'فجر'**
  String get arabicFajr;

  /// No description provided for @arabicSunrise.
  ///
  /// In en, this message translates to:
  /// **'شروق'**
  String get arabicSunrise;

  /// No description provided for @arabicDhuhr.
  ///
  /// In en, this message translates to:
  /// **'ظهر'**
  String get arabicDhuhr;

  /// No description provided for @arabicAsr.
  ///
  /// In en, this message translates to:
  /// **'عصر'**
  String get arabicAsr;

  /// No description provided for @arabicMaghrib.
  ///
  /// In en, this message translates to:
  /// **'مغرب'**
  String get arabicMaghrib;

  /// No description provided for @arabicIsha.
  ///
  /// In en, this message translates to:
  /// **'عشاء'**
  String get arabicIsha;

  /// No description provided for @arabicJumuah.
  ///
  /// In en, this message translates to:
  /// **'جمعة'**
  String get arabicJumuah;

  /// No description provided for @suhoorEnds.
  ///
  /// In en, this message translates to:
  /// **'SUHOOR ENDS'**
  String get suhoorEnds;

  /// No description provided for @iftarTime.
  ///
  /// In en, this message translates to:
  /// **'IFTAR TIME'**
  String get iftarTime;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set location, calculation method, and madhab to start with accurate prayer times.'**
  String get welcomeSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @stepLocation.
  ///
  /// In en, this message translates to:
  /// **'1. Location'**
  String get stepLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter Location'**
  String get enterLocation;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocation;

  /// No description provided for @cityOrAddress.
  ///
  /// In en, this message translates to:
  /// **'City or address'**
  String get cityOrAddress;

  /// No description provided for @noLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'No location selected'**
  String get noLocationSelected;

  /// No description provided for @locationSetTo.
  ///
  /// In en, this message translates to:
  /// **'Location set to {cityName}. Prayer times refreshed.'**
  String locationSetTo(String cityName);

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated and prayer times refreshed.'**
  String get locationUpdated;

  /// No description provided for @unableToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location. Try manual search.'**
  String get unableToGetLocation;

  /// No description provided for @stepCalculationMethod.
  ///
  /// In en, this message translates to:
  /// **'2. Calculation Method'**
  String get stepCalculationMethod;

  /// No description provided for @stepAsrMadhab.
  ///
  /// In en, this message translates to:
  /// **'3. Asr Madhab'**
  String get stepAsrMadhab;

  /// No description provided for @stepFullAdhanPack.
  ///
  /// In en, this message translates to:
  /// **'4. Full Adhan Pack'**
  String get stepFullAdhanPack;

  /// No description provided for @adhanPackNote.
  ///
  /// In en, this message translates to:
  /// **'Notification adhan stays fixed at 30 seconds. This selection is used for full adhan when you tap the notification.'**
  String get adhanPackNote;

  /// No description provided for @methodIsna.
  ///
  /// In en, this message translates to:
  /// **'North America (ISNA)'**
  String get methodIsna;

  /// No description provided for @methodMuslimWorldLeague.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get methodMuslimWorldLeague;

  /// No description provided for @methodTurkeyDiyanet.
  ///
  /// In en, this message translates to:
  /// **'Türkiye Diyanet'**
  String get methodTurkeyDiyanet;

  /// No description provided for @methodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian'**
  String get methodEgyptian;

  /// No description provided for @methodKarachi.
  ///
  /// In en, this message translates to:
  /// **'Karachi (UISC)'**
  String get methodKarachi;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura (Makkah)'**
  String get methodUmmAlQura;

  /// No description provided for @methodDubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai (Gulf Region)'**
  String get methodDubai;

  /// No description provided for @methodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore / SE Asia'**
  String get methodSingapore;

  /// No description provided for @methodTehran.
  ///
  /// In en, this message translates to:
  /// **'Tehran (Iran)'**
  String get methodTehran;

  /// No description provided for @madhabNonHanafi.
  ///
  /// In en, this message translates to:
  /// **'Non-Hanafi'**
  String get madhabNonHanafi;

  /// No description provided for @madhabHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get madhabHanafi;

  /// No description provided for @asrMadhab.
  ///
  /// In en, this message translates to:
  /// **'Asr Madhab'**
  String get asrMadhab;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @calculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get calculation;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @adhanAudio.
  ///
  /// In en, this message translates to:
  /// **'Adhan Audio'**
  String get adhanAudio;

  /// No description provided for @supportAndTrust.
  ///
  /// In en, this message translates to:
  /// **'Support & Trust'**
  String get supportAndTrust;

  /// No description provided for @permissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Permission Needed'**
  String get permissionNeeded;

  /// No description provided for @pleaseAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please allow notifications in iPhone Settings.'**
  String get pleaseAllowNotifications;

  /// No description provided for @fullAdhanOnNotificationTap.
  ///
  /// In en, this message translates to:
  /// **'Full adhan on notification tap'**
  String get fullAdhanOnNotificationTap;

  /// No description provided for @playDuaAfterAdhan.
  ///
  /// In en, this message translates to:
  /// **'Play dua after adhan'**
  String get playDuaAfterAdhan;

  /// No description provided for @adhanPackLabel.
  ///
  /// In en, this message translates to:
  /// **'Adhan Pack: {packName}'**
  String adhanPackLabel(String packName);

  /// No description provided for @adhanPacks.
  ///
  /// In en, this message translates to:
  /// **'Adhan Packs'**
  String get adhanPacks;

  /// No description provided for @downloadAdhanPack.
  ///
  /// In en, this message translates to:
  /// **'Download Adhan Pack'**
  String get downloadAdhanPack;

  /// No description provided for @adhanPackDownloadPrompt.
  ///
  /// In en, this message translates to:
  /// **'{packName} will be downloaded to your device. Continue?'**
  String adhanPackDownloadPrompt(String packName);

  /// No description provided for @downloadingAdhanPack.
  ///
  /// In en, this message translates to:
  /// **'Downloading adhan pack...'**
  String get downloadingAdhanPack;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(String error);

  /// No description provided for @packDownloaded.
  ///
  /// In en, this message translates to:
  /// **'{packName} downloaded.'**
  String packDownloaded(String packName);

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @donateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support development if you wish.'**
  String get donateSubtitle;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open a quick form'**
  String get sendFeedbackSubtitle;

  /// No description provided for @widgetSetup.
  ///
  /// In en, this message translates to:
  /// **'Widget Setup'**
  String get widgetSetup;

  /// No description provided for @widgetSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How to add and refresh the live home screen widget.'**
  String get widgetSetupSubtitle;

  /// No description provided for @privacyNotes.
  ///
  /// In en, this message translates to:
  /// **'Privacy Notes'**
  String get privacyNotes;

  /// No description provided for @privacyNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read how data is handled on-device.'**
  String get privacyNotesSubtitle;

  /// No description provided for @thankYouForUsing.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using Digital Minaret.'**
  String get thankYouForUsing;

  /// No description provided for @appAlwaysFree.
  ///
  /// In en, this message translates to:
  /// **'This app will always stay ad-free and free to use.'**
  String get appAlwaysFree;

  /// No description provided for @rateDigitalMinaret.
  ///
  /// In en, this message translates to:
  /// **'Rate Digital Minaret'**
  String get rateDigitalMinaret;

  /// No description provided for @ratePromptMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you enjoying the spiritual journey? Your feedback helps us illuminate the path.'**
  String get ratePromptMessage;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link on this device.'**
  String get couldNotOpenLink;

  /// No description provided for @couldNotPlayPreview.
  ///
  /// In en, this message translates to:
  /// **'Could not play adhan preview: {error}'**
  String couldNotPlayPreview(String error);

  /// No description provided for @notificationsCouldNotBeScheduled.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be fully scheduled: {error}'**
  String notificationsCouldNotBeScheduled(String error);

  /// No description provided for @couldNotContinue.
  ///
  /// In en, this message translates to:
  /// **'Could not continue. Please try again. ({error})'**
  String couldNotContinue(String error);

  /// No description provided for @hadithOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Hadith of the Day'**
  String get hadithOfTheDay;

  /// No description provided for @ramadanDua.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Dua'**
  String get ramadanDua;

  /// No description provided for @verseFromQuran.
  ///
  /// In en, this message translates to:
  /// **'Verse from the Quran'**
  String get verseFromQuran;

  /// No description provided for @hadithBody.
  ///
  /// In en, this message translates to:
  /// **'The month of Ramadan has come to you, a blessed month which Allah has obligated you to fast. (Nasa\'i)'**
  String get hadithBody;

  /// No description provided for @duaBody.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I ask You for Your love, and the love of those who love You, and the deeds that bring me closer to Your love.'**
  String get duaBody;

  /// No description provided for @verseBody.
  ///
  /// In en, this message translates to:
  /// **'O you who have believed, decreed upon you is fasting as it was decreed upon those before you that you may become righteous. (Al-Baqarah 2:183)'**
  String get verseBody;

  /// No description provided for @supportTheApp.
  ///
  /// In en, this message translates to:
  /// **'Support the App'**
  String get supportTheApp;

  /// No description provided for @donateDescription.
  ///
  /// In en, this message translates to:
  /// **'This app is free and ad-free. If you want, you can support development with a one-time tip.'**
  String get donateDescription;

  /// No description provided for @purchaseDidNotComplete.
  ///
  /// In en, this message translates to:
  /// **'Purchase did not complete.'**
  String get purchaseDidNotComplete;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get thankYou;

  /// No description provided for @thankYouDonateMessage.
  ///
  /// In en, this message translates to:
  /// **'Your support means a lot. This helps keep the app free and ad-free.'**
  String get thankYouDonateMessage;

  /// No description provided for @smallTip.
  ///
  /// In en, this message translates to:
  /// **'Small Tip'**
  String get smallTip;

  /// No description provided for @mediumTip.
  ///
  /// In en, this message translates to:
  /// **'Medium Tip'**
  String get mediumTip;

  /// No description provided for @largeTip.
  ///
  /// In en, this message translates to:
  /// **'Large Tip'**
  String get largeTip;

  /// No description provided for @donationOptionsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Donation options are not available yet.'**
  String get donationOptionsUnavailable;

  /// No description provided for @donationOptionsSetup.
  ///
  /// In en, this message translates to:
  /// **'Add RevenueCat keys and store products (tip_small, tip_medium, tip_large), then retry.'**
  String get donationOptionsSetup;

  /// No description provided for @feedbackSubject.
  ///
  /// In en, this message translates to:
  /// **'Feedback for Digital Minaret'**
  String get feedbackSubject;

  /// No description provided for @mailCouldNotBeOpened.
  ///
  /// In en, this message translates to:
  /// **'Mail app could not be opened.'**
  String get mailCouldNotBeOpened;

  /// No description provided for @openMailApp.
  ///
  /// In en, this message translates to:
  /// **'Open Mail App'**
  String get openMailApp;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @yourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Your feedback'**
  String get yourFeedback;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'This opens your default mail app with prefilled fields.'**
  String get feedbackHint;

  /// No description provided for @privacyNoAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'No account required'**
  String get privacyNoAccountRequired;

  /// No description provided for @privacyNoAccountBody.
  ///
  /// In en, this message translates to:
  /// **'You can use the app without creating an account or sharing personal profile data.'**
  String get privacyNoAccountBody;

  /// No description provided for @privacyLocationOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Location stays on device'**
  String get privacyLocationOnDevice;

  /// No description provided for @privacyLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Location is used only to calculate prayer times and is stored locally on your phone.'**
  String get privacyLocationBody;

  /// No description provided for @privacyNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads, no trackers'**
  String get privacyNoAds;

  /// No description provided for @privacyNoAdsBody.
  ///
  /// In en, this message translates to:
  /// **'The app has no advertising SDK and no analytics tracking by default.'**
  String get privacyNoAdsBody;

  /// No description provided for @privacyNotificationsLocal.
  ///
  /// In en, this message translates to:
  /// **'Notifications are local'**
  String get privacyNotificationsLocal;

  /// No description provided for @privacyNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Prayer notifications are scheduled and triggered directly on device.'**
  String get privacyNotificationsBody;

  /// No description provided for @privacyFeedbackOptIn.
  ///
  /// In en, this message translates to:
  /// **'Feedback is opt-in'**
  String get privacyFeedbackOptIn;

  /// No description provided for @privacyFeedbackBody.
  ///
  /// In en, this message translates to:
  /// **'If you tap feedback, your default mail app opens. Nothing is sent automatically.'**
  String get privacyFeedbackBody;

  /// No description provided for @widgetSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget Setup'**
  String get widgetSetupTitle;

  /// No description provided for @widgetLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Widget'**
  String get widgetLiveTitle;

  /// No description provided for @widgetLiveBody.
  ///
  /// In en, this message translates to:
  /// **'The widget shows current prayer, next prayer and remaining time. Data updates when app calculates/syncs prayer times, and timeline refreshes each minute.'**
  String get widgetLiveBody;

  /// No description provided for @widgetIosTitle.
  ///
  /// In en, this message translates to:
  /// **'iOS'**
  String get widgetIosTitle;

  /// No description provided for @widgetIosBody.
  ///
  /// In en, this message translates to:
  /// **'Long press Home Screen > + > Digital Minaret > choose size > Add Widget.\nIf it does not appear after an update: remove widget, open app once, then add again.'**
  String get widgetIosBody;

  /// No description provided for @widgetAndroidTitle.
  ///
  /// In en, this message translates to:
  /// **'Android'**
  String get widgetAndroidTitle;

  /// No description provided for @widgetAndroidBody.
  ///
  /// In en, this message translates to:
  /// **'Long press Home Screen > Widgets > Digital Minaret.\nIf stale: remove/re-add widget and open app once to push fresh times.'**
  String get widgetAndroidBody;

  /// No description provided for @widgetTypographyTitle.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get widgetTypographyTitle;

  /// No description provided for @widgetTypographyBody.
  ///
  /// In en, this message translates to:
  /// **'Widget typography is aligned with app style (Cinzel + Manrope) on both iOS and Android.'**
  String get widgetTypographyBody;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @towardsTheQibla.
  ///
  /// In en, this message translates to:
  /// **'TOWARDS THE QIBLA'**
  String get towardsTheQibla;

  /// No description provided for @compassNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Compass sensor not available on this device.'**
  String get compassNotAvailable;

  /// No description provided for @locationRequiredForQibla.
  ///
  /// In en, this message translates to:
  /// **'Location is required to determine Qibla direction.'**
  String get locationRequiredForQibla;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'fa',
    'fr',
    'id',
    'tr',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
