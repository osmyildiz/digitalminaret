// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'ڈیجیٹل مینارہ';

  @override
  String get prayerFajr => 'فجر';

  @override
  String get prayerSunrise => 'طلوع آفتاب';

  @override
  String get prayerDhuhr => 'ظہر';

  @override
  String get prayerAsr => 'عصر';

  @override
  String get prayerMaghrib => 'مغرب';

  @override
  String get prayerIsha => 'عشاء';

  @override
  String get prayerJumuah => 'جمعہ';

  @override
  String get prayerIftar => 'افطار';

  @override
  String get prayerSuhoor => 'سحری';

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
  String get suhoorEnds => 'سحری ختم';

  @override
  String get iftarTime => 'افطار کا وقت';

  @override
  String get unknown => 'نامعلوم';

  @override
  String get welcome => 'خوش آمدید';

  @override
  String get welcomeSubtitle =>
      'درست نماز اوقات کے لیے مقام، حساب کا طریقہ اور مذہب منتخب کریں۔';

  @override
  String get continueButton => 'جاری رکھیں';

  @override
  String get close => 'بند کریں';

  @override
  String get ok => 'ٹھیک ہے';

  @override
  String get notNow => 'ابھی نہیں';

  @override
  String get submit => 'جمع کرائیں';

  @override
  String get cancel => 'منسوخ';

  @override
  String get download => 'ڈاؤن لوڈ';

  @override
  String get retry => 'دوبارہ کوشش';

  @override
  String get settings => 'ترتیبات';

  @override
  String get stepLocation => '1. مقام';

  @override
  String get useCurrentLocation => 'موجودہ مقام استعمال کریں';

  @override
  String get enterLocation => 'مقام درج کریں';

  @override
  String get searchLocation => 'مقام تلاش کریں';

  @override
  String get cityOrAddress => 'شہر یا پتہ';

  @override
  String get noLocationSelected => 'کوئی مقام منتخب نہیں ہے';

  @override
  String locationSetTo(String cityName) {
    return 'مقام $cityName پر سیٹ ہو گیا۔ نماز اوقات تازہ ہو گئے۔';
  }

  @override
  String get locationUpdated =>
      'مقام اپ ڈیٹ ہو گیا اور نماز اوقات تازہ ہو گئے۔';

  @override
  String get unableToGetLocation => 'مقام حاصل نہیں ہو سکا۔ دستی تلاش آزمائیں۔';

  @override
  String get stepCalculationMethod => '2. حساب کا طریقہ';

  @override
  String get stepAsrMadhab => '3. عصر مذہب';

  @override
  String get stepFullAdhanPack => '4. مکمل اذان پیک';

  @override
  String get adhanPackNote =>
      'نوٹیفکیشن اذان 30 سیکنڈ پر مقرر رہتی ہے۔ یہ انتخاب نوٹیفکیشن پر ٹیپ کرنے پر مکمل اذان کے لیے استعمال ہوتا ہے۔';

  @override
  String get methodIsna => 'شمالی امریکہ (ISNA)';

  @override
  String get methodMuslimWorldLeague => 'مسلم ورلڈ لیگ';

  @override
  String get methodTurkeyDiyanet => 'ترکیہ دیانت';

  @override
  String get methodEgyptian => 'مصری';

  @override
  String get methodKarachi => 'کراچی (UISC)';

  @override
  String get methodUmmAlQura => 'ام القریٰ (مکہ)';

  @override
  String get methodDubai => 'دبئی (خلیجی خطہ)';

  @override
  String get methodSingapore => 'سنگاپور / جنوب مشرقی ایشیا';

  @override
  String get methodTehran => 'تہران (ایران)';

  @override
  String get madhabNonHanafi => 'غیر حنفی';

  @override
  String get madhabHanafi => 'حنفی';

  @override
  String get asrMadhab => 'عصر مذہب';

  @override
  String get location => 'مقام';

  @override
  String get calculation => 'حساب';

  @override
  String get notifications => 'اطلاعات';

  @override
  String get adhanAudio => 'اذان آڈیو';

  @override
  String get supportAndTrust => 'تعاون اور اعتماد';

  @override
  String get permissionNeeded => 'اجازت درکار ہے';

  @override
  String get pleaseAllowNotifications =>
      'براہ کرم آئی فون سیٹنگز میں اطلاعات کی اجازت دیں۔';

  @override
  String get fullAdhanOnNotificationTap => 'نوٹیفکیشن پر ٹیپ کرنے سے مکمل اذان';

  @override
  String get playDuaAfterAdhan => 'اذان کے بعد دعا سنائیں';

  @override
  String adhanPackLabel(String packName) {
    return 'اذان پیک: $packName';
  }

  @override
  String get adhanPacks => 'اذان پیکس';

  @override
  String get downloadAdhanPack => 'اذان پیک ڈاؤن لوڈ کریں';

  @override
  String adhanPackDownloadPrompt(String packName) {
    return '$packName آپ کے آلے پر ڈاؤن لوڈ ہو گا۔ جاری رکھیں؟';
  }

  @override
  String get downloadingAdhanPack => 'اذان پیک ڈاؤن لوڈ ہو رہا ہے...';

  @override
  String downloadFailed(String error) {
    return 'ڈاؤن لوڈ ناکام: $error';
  }

  @override
  String packDownloaded(String packName) {
    return '$packName ڈاؤن لوڈ ہو گیا۔';
  }

  @override
  String get donate => 'عطیہ دیں';

  @override
  String get donateSubtitle => 'اگر چاہیں تو ترقی میں تعاون کریں۔';

  @override
  String get sendFeedback => 'رائے بھیجیں';

  @override
  String get sendFeedbackSubtitle => 'ایک فوری فارم کھولیں';

  @override
  String get widgetSetup => 'ویجیٹ سیٹ اپ';

  @override
  String get widgetSetupSubtitle =>
      'لائیو ہوم اسکرین ویجیٹ کیسے شامل اور تازہ کریں۔';

  @override
  String get privacyNotes => 'رازداری کے نوٹس';

  @override
  String get privacyNotesSubtitle =>
      'پڑھیں کہ ڈیٹا آلے پر کیسے سنبھالا جاتا ہے۔';

  @override
  String get thankYouForUsing => 'ڈیجیٹل مینارہ استعمال کرنے کا شکریہ۔';

  @override
  String get appAlwaysFree => 'یہ ایپ ہمیشہ اشتہارات سے پاک اور مفت رہے گی۔';

  @override
  String get rateDigitalMinaret => 'ڈیجیٹل مینارہ کی درجہ بندی کریں';

  @override
  String get ratePromptMessage =>
      'کیا آپ روحانی سفر سے لطف اندوز ہو رہے ہیں؟ آپ کی رائے ہمیں راستہ روشن کرنے میں مدد کرتی ہے۔';

  @override
  String get couldNotOpenLink => 'اس آلے پر لنک نہیں کھولا جا سکا۔';

  @override
  String couldNotPlayPreview(String error) {
    return 'اذان پیش نظارہ نہیں چلایا جا سکا: $error';
  }

  @override
  String notificationsCouldNotBeScheduled(String error) {
    return 'اطلاعات مکمل طور پر شیڈول نہیں ہو سکیں: $error';
  }

  @override
  String couldNotContinue(String error) {
    return 'جاری نہیں رکھ سکے۔ براہ کرم دوبارہ کوشش کریں۔ ($error)';
  }

  @override
  String get hadithOfTheDay => 'آج کی حدیث';

  @override
  String get ramadanDua => 'رمضان کی دعا';

  @override
  String get verseFromQuran => 'قرآن کی آیت';

  @override
  String get hadithBody =>
      'تمہارے پاس رمضان کا مہینہ آیا ہے، ایک بابرکت مہینہ جس میں اللہ نے تم پر روزہ فرض کیا ہے۔ (نسائی)';

  @override
  String get duaBody =>
      'اے اللہ، میں تجھ سے تیری محبت مانگتا ہوں، اور ان کی محبت جو تجھ سے محبت کرتے ہیں، اور وہ اعمال جو مجھے تیری محبت کے قریب کریں۔';

  @override
  String get verseBody =>
      'اے ایمان والو، تم پر روزے فرض کیے گئے ہیں جیسا کہ تم سے پہلے لوگوں پر فرض کیے گئے تھے تاکہ تم تقویٰ اختیار کرو۔ (البقرہ 2:183)';

  @override
  String get supportTheApp => 'ایپ کی مدد کریں';

  @override
  String get donateDescription =>
      'یہ ایپ مفت اور اشتہارات سے پاک ہے۔ اگر آپ چاہیں تو ایک وقتی ٹپ سے ترقی میں مدد کر سکتے ہیں۔';

  @override
  String get purchaseDidNotComplete => 'خریداری مکمل نہیں ہوئی۔';

  @override
  String get thankYou => 'شکریہ';

  @override
  String get thankYouDonateMessage =>
      'آپ کے تعاون کی بہت قدر ہے۔ اس سے ایپ مفت اور اشتہارات سے پاک رکھنے میں مدد ملتی ہے۔';

  @override
  String get smallTip => 'چھوٹی ٹپ';

  @override
  String get mediumTip => 'درمیانی ٹپ';

  @override
  String get largeTip => 'بڑی ٹپ';

  @override
  String get donationOptionsUnavailable =>
      'عطیہ کے اختیارات ابھی دستیاب نہیں ہیں۔';

  @override
  String get donationOptionsSetup =>
      'RevenueCat کیز اور اسٹور پروڈکٹس (tip_small, tip_medium, tip_large) شامل کریں، پھر دوبارہ کوشش کریں۔';

  @override
  String get feedbackSubject => 'ڈیجیٹل مینارہ کے لیے رائے';

  @override
  String get mailCouldNotBeOpened => 'میل ایپ نہیں کھولی جا سکی۔';

  @override
  String get openMailApp => 'میل ایپ کھولیں';

  @override
  String get subject => 'موضوع';

  @override
  String get yourFeedback => 'آپ کی رائے';

  @override
  String get feedbackHint =>
      'یہ آپ کی ڈیفالٹ میل ایپ پہلے سے بھرے فیلڈز کے ساتھ کھولتا ہے۔';

  @override
  String get privacyNoAccountRequired => 'کسی اکاؤنٹ کی ضرورت نہیں';

  @override
  String get privacyNoAccountBody =>
      'آپ بغیر اکاؤنٹ بنائے یا ذاتی معلومات شیئر کیے ایپ استعمال کر سکتے ہیں۔';

  @override
  String get privacyLocationOnDevice => 'مقام آلے پر رہتا ہے';

  @override
  String get privacyLocationBody =>
      'مقام صرف نماز اوقات کے حساب کے لیے استعمال ہوتا ہے اور آپ کے فون پر مقامی طور پر محفوظ رہتا ہے۔';

  @override
  String get privacyNoAds => 'نہ اشتہارات، نہ ٹریکرز';

  @override
  String get privacyNoAdsBody =>
      'ایپ میں کوئی اشتہاری SDK نہیں ہے اور بطور ڈیفالٹ کوئی تجزیاتی ٹریکنگ نہیں ہے۔';

  @override
  String get privacyNotificationsLocal => 'اطلاعات مقامی ہیں';

  @override
  String get privacyNotificationsBody =>
      'نماز کی اطلاعات براہ راست آلے پر شیڈول اور متحرک ہوتی ہیں۔';

  @override
  String get privacyFeedbackOptIn => 'رائے اختیاری ہے';

  @override
  String get privacyFeedbackBody =>
      'اگر آپ رائے پر ٹیپ کریں تو آپ کی ڈیفالٹ میل ایپ کھلتی ہے۔ خودکار طور پر کچھ نہیں بھیجا جاتا۔';

  @override
  String get widgetSetupTitle => 'ویجیٹ سیٹ اپ';

  @override
  String get widgetLiveTitle => 'لائیو ویجیٹ';

  @override
  String get widgetLiveBody =>
      'ویجیٹ موجودہ نماز، اگلی نماز اور باقی وقت دکھاتا ہے۔ ایپ نماز اوقات کا حساب/ہم آہنگی کرنے پر ڈیٹا اپ ڈیٹ ہوتا ہے، اور ٹائم لائن ہر منٹ تازہ ہوتی ہے۔';

  @override
  String get widgetIosTitle => 'iOS';

  @override
  String get widgetIosBody =>
      'ہوم اسکرین پر دیر تک دبائیں > + > Digital Minaret > سائز منتخب کریں > ویجیٹ شامل کریں۔\nاگر اپ ڈیٹ کے بعد ظاہر نہ ہو: ویجیٹ ہٹائیں، ایپ ایک بار کھولیں، پھر دوبارہ شامل کریں۔';

  @override
  String get widgetAndroidTitle => 'Android';

  @override
  String get widgetAndroidBody =>
      'ہوم اسکرین پر دیر تک دبائیں > ویجیٹس > Digital Minaret۔\nاگر پرانا ہو: ویجیٹ ہٹا کر دوبارہ شامل کریں اور تازہ اوقات بھیجنے کے لیے ایپ ایک بار کھولیں۔';

  @override
  String get widgetTypographyTitle => 'ٹائپوگرافی';

  @override
  String get widgetTypographyBody =>
      'ویجیٹ ٹائپوگرافی iOS اور Android دونوں پر ایپ کے انداز (Cinzel + Manrope) سے ہم آہنگ ہے۔';

  @override
  String get language => 'زبان';

  @override
  String get qibla => 'قبلہ';

  @override
  String get towardsTheQibla => 'قبلے کی سمت';

  @override
  String get compassNotAvailable => 'اس آلے پر قطب نما سینسر دستیاب نہیں ہے۔';

  @override
  String get locationRequiredForQibla =>
      'قبلے کی سمت معلوم کرنے کے لیے مقام درکار ہے۔';
}
