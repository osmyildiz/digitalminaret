// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'المئذنة الرقمية';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get prayerJumuah => 'الجمعة';

  @override
  String get prayerIftar => 'الإفطار';

  @override
  String get prayerSuhoor => 'السحور';

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
  String get suhoorEnds => 'ينتهي السحور';

  @override
  String get iftarTime => 'وقت الإفطار';

  @override
  String get unknown => 'غير معروف';

  @override
  String get welcome => 'مرحباً';

  @override
  String get welcomeSubtitle =>
      'حدّد الموقع وطريقة الحساب والمذهب للبدء بمواقيت صلاة دقيقة.';

  @override
  String get continueButton => 'متابعة';

  @override
  String get close => 'إغلاق';

  @override
  String get ok => 'حسناً';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get submit => 'إرسال';

  @override
  String get cancel => 'إلغاء';

  @override
  String get download => 'تحميل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get stepLocation => '١. الموقع';

  @override
  String get useCurrentLocation => 'استخدام الموقع الحالي';

  @override
  String get enterLocation => 'إدخال الموقع';

  @override
  String get searchLocation => 'البحث عن موقع';

  @override
  String get cityOrAddress => 'المدينة أو العنوان';

  @override
  String get noLocationSelected => 'لم يتم اختيار موقع';

  @override
  String locationSetTo(String cityName) {
    return 'تم تعيين الموقع إلى $cityName. تم تحديث مواقيت الصلاة.';
  }

  @override
  String get locationUpdated => 'تم تحديث الموقع ومواقيت الصلاة.';

  @override
  String get unableToGetLocation => 'تعذّر تحديد الموقع. جرّب البحث اليدوي.';

  @override
  String get stepCalculationMethod => '٢. طريقة الحساب';

  @override
  String get stepAsrMadhab => '٣. مذهب العصر';

  @override
  String get stepFullAdhanPack => '٤. حزمة الأذان الكاملة';

  @override
  String get adhanPackNote =>
      'يبقى أذان الإشعار ثابتاً عند ٣٠ ثانية. يُستخدم هذا الاختيار للأذان الكامل عند الضغط على الإشعار.';

  @override
  String get methodIsna => 'أمريكا الشمالية (ISNA)';

  @override
  String get methodMuslimWorldLeague => 'رابطة العالم الإسلامي';

  @override
  String get methodTurkeyDiyanet => 'الشؤون الدينية التركية (ديانت)';

  @override
  String get methodEgyptian => 'الهيئة المصرية';

  @override
  String get methodKarachi => 'كراتشي (UISC)';

  @override
  String get methodUmmAlQura => 'أم القرى (مكة)';

  @override
  String get methodDubai => 'دبي (منطقة الخليج)';

  @override
  String get methodSingapore => 'سنغافورة / جنوب شرق آسيا';

  @override
  String get methodTehran => 'طهران (إيران)';

  @override
  String get madhabNonHanafi => 'غير حنفي';

  @override
  String get madhabHanafi => 'حنفي';

  @override
  String get asrMadhab => 'مذهب العصر';

  @override
  String get location => 'الموقع';

  @override
  String get calculation => 'الحساب';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get adhanAudio => 'صوت الأذان';

  @override
  String get supportAndTrust => 'الدعم والثقة';

  @override
  String get permissionNeeded => 'يلزم إذن';

  @override
  String get pleaseAllowNotifications =>
      'يرجى السماح بالإشعارات من إعدادات الجهاز.';

  @override
  String get fullAdhanOnNotificationTap =>
      'تشغيل الأذان الكامل عند الضغط على الإشعار';

  @override
  String get playDuaAfterAdhan => 'تشغيل الدعاء بعد الأذان';

  @override
  String adhanPackLabel(String packName) {
    return 'حزمة الأذان: $packName';
  }

  @override
  String get adhanPacks => 'حزم الأذان';

  @override
  String get downloadAdhanPack => 'تحميل حزمة الأذان';

  @override
  String adhanPackDownloadPrompt(String packName) {
    return 'سيتم تحميل $packName على جهازك. هل تريد المتابعة؟';
  }

  @override
  String get downloadingAdhanPack => 'جارٍ تحميل حزمة الأذان...';

  @override
  String downloadFailed(String error) {
    return 'فشل التحميل: $error';
  }

  @override
  String packDownloaded(String packName) {
    return 'تم تحميل $packName.';
  }

  @override
  String get donate => 'تبرّع';

  @override
  String get donateSubtitle => 'ادعم التطوير إن رغبت.';

  @override
  String get sendFeedback => 'إرسال ملاحظات';

  @override
  String get sendFeedbackSubtitle => 'افتح نموذجاً سريعاً';

  @override
  String get widgetSetup => 'إعداد الودجت';

  @override
  String get widgetSetupSubtitle => 'كيفية إضافة وتحديث ودجت الشاشة الرئيسية.';

  @override
  String get privacyNotes => 'ملاحظات الخصوصية';

  @override
  String get privacyNotesSubtitle => 'اقرأ كيفية معالجة البيانات على الجهاز.';

  @override
  String get thankYouForUsing => 'شكراً لاستخدامك المئذنة الرقمية.';

  @override
  String get appAlwaysFree =>
      'سيظل هذا التطبيق مجانياً وخالياً من الإعلانات دائماً.';

  @override
  String get rateDigitalMinaret => 'قيّم المئذنة الرقمية';

  @override
  String get ratePromptMessage =>
      'هل تستمتع بالرحلة الروحية؟ ملاحظاتك تساعدنا على إنارة الطريق.';

  @override
  String get couldNotOpenLink => 'تعذّر فتح الرابط على هذا الجهاز.';

  @override
  String couldNotPlayPreview(String error) {
    return 'تعذّر تشغيل معاينة الأذان: $error';
  }

  @override
  String notificationsCouldNotBeScheduled(String error) {
    return 'تعذّرت جدولة الإشعارات بالكامل: $error';
  }

  @override
  String couldNotContinue(String error) {
    return 'تعذّرت المتابعة. يرجى المحاولة مرة أخرى. ($error)';
  }

  @override
  String get hadithOfTheDay => 'حديث اليوم';

  @override
  String get ramadanDua => 'دعاء رمضان';

  @override
  String get verseFromQuran => 'آية من القرآن الكريم';

  @override
  String get hadithBody =>
      'أتاكم شهر رمضان، شهرٌ مبارك فرض الله عليكم صيامه. (النسائي)';

  @override
  String get duaBody =>
      'اللهم إني أسألك حبّك، وحبّ من يحبّك، والعمل الذي يبلّغني حبّك.';

  @override
  String get verseBody =>
      'يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ كَمَا كُتِبَ عَلَى الَّذِينَ مِن قَبْلِكُمْ لَعَلَّكُمْ تَتَّقُونَ. (البقرة ٢:١٨٣)';

  @override
  String get supportTheApp => 'ادعم التطبيق';

  @override
  String get donateDescription =>
      'هذا التطبيق مجاني وخالٍ من الإعلانات. إن أردت، يمكنك دعم التطوير بتبرّع لمرة واحدة.';

  @override
  String get purchaseDidNotComplete => 'لم تكتمل عملية الشراء.';

  @override
  String get thankYou => 'شكراً لك';

  @override
  String get thankYouDonateMessage =>
      'دعمك يعني لنا الكثير. يساعد هذا في إبقاء التطبيق مجانياً وخالياً من الإعلانات.';

  @override
  String get smallTip => 'تبرّع صغير';

  @override
  String get mediumTip => 'تبرّع متوسط';

  @override
  String get largeTip => 'تبرّع كبير';

  @override
  String get donationOptionsUnavailable => 'خيارات التبرّع غير متاحة بعد.';

  @override
  String get donationOptionsSetup =>
      'أضف مفاتيح RevenueCat ومنتجات المتجر (tip_small, tip_medium, tip_large)، ثم أعد المحاولة.';

  @override
  String get feedbackSubject => 'ملاحظات حول المئذنة الرقمية';

  @override
  String get mailCouldNotBeOpened => 'تعذّر فتح تطبيق البريد.';

  @override
  String get openMailApp => 'فتح تطبيق البريد';

  @override
  String get subject => 'الموضوع';

  @override
  String get yourFeedback => 'ملاحظاتك';

  @override
  String get feedbackHint =>
      'سيفتح هذا تطبيق البريد الافتراضي مع حقول معبّأة مسبقاً.';

  @override
  String get privacyNoAccountRequired => 'لا يلزم إنشاء حساب';

  @override
  String get privacyNoAccountBody =>
      'يمكنك استخدام التطبيق دون إنشاء حساب أو مشاركة بيانات شخصية.';

  @override
  String get privacyLocationOnDevice => 'الموقع يبقى على الجهاز';

  @override
  String get privacyLocationBody =>
      'يُستخدم الموقع فقط لحساب مواقيت الصلاة ويُخزَّن محلياً على هاتفك.';

  @override
  String get privacyNoAds => 'لا إعلانات ولا تتبّع';

  @override
  String get privacyNoAdsBody =>
      'لا يحتوي التطبيق على أي حزمة إعلانية أو تتبّع تحليلي افتراضياً.';

  @override
  String get privacyNotificationsLocal => 'الإشعارات محلية';

  @override
  String get privacyNotificationsBody =>
      'تُجدوَل إشعارات الصلاة وتُطلَق مباشرة على الجهاز.';

  @override
  String get privacyFeedbackOptIn => 'الملاحظات اختيارية';

  @override
  String get privacyFeedbackBody =>
      'عند الضغط على الملاحظات، يُفتح تطبيق البريد الافتراضي. لا يُرسَل شيء تلقائياً.';

  @override
  String get widgetSetupTitle => 'إعداد الودجت';

  @override
  String get widgetLiveTitle => 'ودجت مباشر';

  @override
  String get widgetLiveBody =>
      'يعرض الودجت الصلاة الحالية والصلاة التالية والوقت المتبقي. تُحدَّث البيانات عند حساب/مزامنة مواقيت الصلاة، ويُحدَّث الجدول الزمني كل دقيقة.';

  @override
  String get widgetIosTitle => 'iOS';

  @override
  String get widgetIosBody =>
      'اضغط مطوّلاً على الشاشة الرئيسية > + > المئذنة الرقمية > اختر الحجم > إضافة الودجت.\nإذا لم يظهر بعد التحديث: أزل الودجت، افتح التطبيق مرة، ثم أضفه مجدداً.';

  @override
  String get widgetAndroidTitle => 'Android';

  @override
  String get widgetAndroidBody =>
      'اضغط مطوّلاً على الشاشة الرئيسية > الودجات > المئذنة الرقمية.\nإذا كانت البيانات قديمة: أزل الودجت وأعد إضافته، وافتح التطبيق مرة لإرسال مواقيت جديدة.';

  @override
  String get widgetTypographyTitle => 'الخطوط';

  @override
  String get widgetTypographyBody =>
      'خطوط الودجت متوافقة مع نمط التطبيق (Cinzel + Manrope) على كل من iOS وAndroid.';

  @override
  String get language => 'اللغة';

  @override
  String get qibla => 'القبلة';

  @override
  String get towardsTheQibla => 'اتجاه القبلة';

  @override
  String get compassNotAvailable => 'مستشعر البوصلة غير متوفر على هذا الجهاز.';

  @override
  String get locationRequiredForQibla => 'الموقع مطلوب لتحديد اتجاه القبلة.';
}
