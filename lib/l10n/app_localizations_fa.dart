// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'مناره دیجیتال';

  @override
  String get prayerFajr => 'فجر';

  @override
  String get prayerSunrise => 'طلوع آفتاب';

  @override
  String get prayerDhuhr => 'ظهر';

  @override
  String get prayerAsr => 'عصر';

  @override
  String get prayerMaghrib => 'مغرب';

  @override
  String get prayerIsha => 'عشاء';

  @override
  String get prayerJumuah => 'جمعه';

  @override
  String get prayerIftar => 'افطار';

  @override
  String get prayerSuhoor => 'سحر';

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
  String get suhoorEnds => 'پایان سحر';

  @override
  String get iftarTime => 'وقت افطار';

  @override
  String get unknown => 'نامشخص';

  @override
  String get welcome => 'خوش آمدید';

  @override
  String get welcomeSubtitle =>
      'برای شروع با اوقات دقیق نماز، موقعیت مکانی، روش محاسبه و مذهب را تنظیم کنید.';

  @override
  String get continueButton => 'ادامه';

  @override
  String get close => 'بستن';

  @override
  String get ok => 'تأیید';

  @override
  String get notNow => 'الان نه';

  @override
  String get submit => 'ارسال';

  @override
  String get cancel => 'لغو';

  @override
  String get download => 'دانلود';

  @override
  String get retry => 'تلاش مجدد';

  @override
  String get settings => 'تنظیمات';

  @override
  String get stepLocation => '۱. موقعیت مکانی';

  @override
  String get useCurrentLocation => 'استفاده از موقعیت فعلی';

  @override
  String get enterLocation => 'وارد کردن موقعیت';

  @override
  String get searchLocation => 'جستجوی موقعیت';

  @override
  String get cityOrAddress => 'شهر یا آدرس';

  @override
  String get noLocationSelected => 'موقعیتی انتخاب نشده است';

  @override
  String locationSetTo(String cityName) {
    return 'موقعیت روی $cityName تنظیم شد. اوقات نماز به‌روزرسانی شد.';
  }

  @override
  String get locationUpdated => 'موقعیت به‌روزرسانی و اوقات نماز تازه‌سازی شد.';

  @override
  String get unableToGetLocation =>
      'دریافت موقعیت ممکن نشد. جستجوی دستی را امتحان کنید.';

  @override
  String get stepCalculationMethod => '۲. روش محاسبه';

  @override
  String get stepAsrMadhab => '۳. مذهب عصر';

  @override
  String get stepFullAdhanPack => '۴. بسته اذان کامل';

  @override
  String get adhanPackNote =>
      'اذان اعلان همیشه ۳۰ ثانیه ثابت است. این انتخاب برای اذان کامل هنگام لمس اعلان استفاده می‌شود.';

  @override
  String get methodIsna => 'آمریکای شمالی (ISNA)';

  @override
  String get methodMuslimWorldLeague => 'مجمع جهانی اسلام';

  @override
  String get methodTurkeyDiyanet => 'دیانت ترکیه';

  @override
  String get methodEgyptian => 'مصری';

  @override
  String get methodKarachi => 'کراچی (UISC)';

  @override
  String get methodUmmAlQura => 'ام‌القری (مکه)';

  @override
  String get methodDubai => 'دبی (منطقه خلیج)';

  @override
  String get methodSingapore => 'سنگاپور / جنوب شرق آسیا';

  @override
  String get methodTehran => 'تهران (ایران)';

  @override
  String get madhabNonHanafi => 'غیر حنفی';

  @override
  String get madhabHanafi => 'حنفی';

  @override
  String get asrMadhab => 'مذهب عصر';

  @override
  String get location => 'موقعیت مکانی';

  @override
  String get calculation => 'محاسبه';

  @override
  String get notifications => 'اعلان‌ها';

  @override
  String get adhanAudio => 'صدای اذان';

  @override
  String get supportAndTrust => 'حمایت و اعتماد';

  @override
  String get permissionNeeded => 'نیاز به مجوز';

  @override
  String get pleaseAllowNotifications =>
      'لطفاً اعلان‌ها را در تنظیمات آیفون فعال کنید.';

  @override
  String get fullAdhanOnNotificationTap => 'پخش اذان کامل با لمس اعلان';

  @override
  String get playDuaAfterAdhan => 'پخش دعا بعد از اذان';

  @override
  String adhanPackLabel(String packName) {
    return 'بسته اذان: $packName';
  }

  @override
  String get adhanPacks => 'بسته‌های اذان';

  @override
  String get downloadAdhanPack => 'دانلود بسته اذان';

  @override
  String adhanPackDownloadPrompt(String packName) {
    return '$packName روی دستگاه شما دانلود خواهد شد. ادامه می‌دهید؟';
  }

  @override
  String get downloadingAdhanPack => 'در حال دانلود بسته اذان...';

  @override
  String downloadFailed(String error) {
    return 'دانلود ناموفق: $error';
  }

  @override
  String packDownloaded(String packName) {
    return '$packName دانلود شد.';
  }

  @override
  String get donate => 'حمایت مالی';

  @override
  String get donateSubtitle => 'در صورت تمایل از توسعه حمایت کنید.';

  @override
  String get sendFeedback => 'ارسال بازخورد';

  @override
  String get sendFeedbackSubtitle => 'باز کردن فرم سریع';

  @override
  String get widgetSetup => 'تنظیم ویجت';

  @override
  String get widgetSetupSubtitle =>
      'نحوه افزودن و به‌روزرسانی ویجت زنده صفحه اصلی.';

  @override
  String get privacyNotes => 'نکات حریم خصوصی';

  @override
  String get privacyNotesSubtitle =>
      'نحوه مدیریت داده‌ها روی دستگاه را بخوانید.';

  @override
  String get thankYouForUsing => 'از استفاده شما از مناره دیجیتال سپاسگزاریم.';

  @override
  String get appAlwaysFree =>
      'این برنامه همیشه بدون تبلیغ و رایگان خواهد ماند.';

  @override
  String get rateDigitalMinaret => 'امتیاز به مناره دیجیتال';

  @override
  String get ratePromptMessage =>
      'آیا از این سفر معنوی لذت می‌برید؟ بازخورد شما به ما کمک می‌کند تا راه را روشن‌تر کنیم.';

  @override
  String get couldNotOpenLink => 'باز کردن لینک روی این دستگاه ممکن نشد.';

  @override
  String couldNotPlayPreview(String error) {
    return 'پخش پیش‌نمایش اذان ممکن نشد: $error';
  }

  @override
  String notificationsCouldNotBeScheduled(String error) {
    return 'زمان‌بندی کامل اعلان‌ها ممکن نشد: $error';
  }

  @override
  String couldNotContinue(String error) {
    return 'ادامه ممکن نشد. لطفاً دوباره تلاش کنید. ($error)';
  }

  @override
  String get hadithOfTheDay => 'حدیث روز';

  @override
  String get ramadanDua => 'دعای رمضان';

  @override
  String get verseFromQuran => 'آیه‌ای از قرآن';

  @override
  String get hadithBody =>
      'ماه رمضان بر شما فرا رسیده است، ماه مبارکی که خداوند روزه آن را بر شما واجب کرده است. (نسائی)';

  @override
  String get duaBody =>
      'خدایا، از تو محبتت را می‌خواهم، و محبت کسانی که تو را دوست دارند، و اعمالی که مرا به محبت تو نزدیک‌تر کند.';

  @override
  String get verseBody =>
      'ای کسانی که ایمان آورده‌اید، روزه بر شما واجب شده، همان‌گونه که بر پیشینیان شما واجب شده بود، تا پرهیزگار شوید. (بقره ۱۸۳)';

  @override
  String get supportTheApp => 'حمایت از برنامه';

  @override
  String get donateDescription =>
      'این برنامه رایگان و بدون تبلیغ است. در صورت تمایل می‌توانید با یک کمک مالی از توسعه حمایت کنید.';

  @override
  String get purchaseDidNotComplete => 'خرید تکمیل نشد.';

  @override
  String get thankYou => 'سپاسگزاریم';

  @override
  String get thankYouDonateMessage =>
      'حمایت شما بسیار ارزشمند است. این کمک می‌کند برنامه رایگان و بدون تبلیغ بماند.';

  @override
  String get smallTip => 'کمک کوچک';

  @override
  String get mediumTip => 'کمک متوسط';

  @override
  String get largeTip => 'کمک بزرگ';

  @override
  String get donationOptionsUnavailable =>
      'گزینه‌های حمایت مالی هنوز در دسترس نیست.';

  @override
  String get donationOptionsSetup =>
      'کلیدهای RevenueCat و محصولات فروشگاه (tip_small, tip_medium, tip_large) را اضافه کنید، سپس دوباره تلاش کنید.';

  @override
  String get feedbackSubject => 'بازخورد برای مناره دیجیتال';

  @override
  String get mailCouldNotBeOpened => 'برنامه ایمیل باز نشد.';

  @override
  String get openMailApp => 'باز کردن برنامه ایمیل';

  @override
  String get subject => 'موضوع';

  @override
  String get yourFeedback => 'بازخورد شما';

  @override
  String get feedbackHint =>
      'این کار برنامه ایمیل پیش‌فرض شما را با فیلدهای از پیش پر شده باز می‌کند.';

  @override
  String get privacyNoAccountRequired => 'نیازی به حساب کاربری نیست';

  @override
  String get privacyNoAccountBody =>
      'می‌توانید بدون ایجاد حساب کاربری یا اشتراک‌گذاری اطلاعات شخصی از برنامه استفاده کنید.';

  @override
  String get privacyLocationOnDevice => 'موقعیت مکانی روی دستگاه می‌ماند';

  @override
  String get privacyLocationBody =>
      'موقعیت مکانی فقط برای محاسبه اوقات نماز استفاده می‌شود و به صورت محلی روی گوشی شما ذخیره می‌شود.';

  @override
  String get privacyNoAds => 'بدون تبلیغ، بدون ردیاب';

  @override
  String get privacyNoAdsBody =>
      'این برنامه هیچ SDK تبلیغاتی و هیچ ردیابی تحلیلی به صورت پیش‌فرض ندارد.';

  @override
  String get privacyNotificationsLocal => 'اعلان‌ها محلی هستند';

  @override
  String get privacyNotificationsBody =>
      'اعلان‌های نماز مستقیماً روی دستگاه زمان‌بندی و اجرا می‌شوند.';

  @override
  String get privacyFeedbackOptIn => 'بازخورد اختیاری است';

  @override
  String get privacyFeedbackBody =>
      'اگر بازخورد را لمس کنید، برنامه ایمیل پیش‌فرض شما باز می‌شود. هیچ چیزی به صورت خودکار ارسال نمی‌شود.';

  @override
  String get widgetSetupTitle => 'تنظیم ویجت';

  @override
  String get widgetLiveTitle => 'ویجت زنده';

  @override
  String get widgetLiveBody =>
      'ویجت نماز فعلی، نماز بعدی و زمان باقی‌مانده را نشان می‌دهد. داده‌ها هنگام محاسبه/همگام‌سازی اوقات نماز به‌روز می‌شوند و خط زمانی هر دقیقه تازه‌سازی می‌شود.';

  @override
  String get widgetIosTitle => 'iOS';

  @override
  String get widgetIosBody =>
      'صفحه اصلی را لمس طولانی کنید > + > مناره دیجیتال > اندازه را انتخاب کنید > افزودن ویجت.\nاگر بعد از به‌روزرسانی ظاهر نشد: ویجت را حذف کنید، برنامه را یک بار باز کنید، سپس دوباره اضافه کنید.';

  @override
  String get widgetAndroidTitle => 'اندروید';

  @override
  String get widgetAndroidBody =>
      'صفحه اصلی را لمس طولانی کنید > ویجت‌ها > مناره دیجیتال.\nاگر قدیمی شد: ویجت را حذف و دوباره اضافه کنید و برنامه را یک بار باز کنید تا اوقات تازه ارسال شود.';

  @override
  String get widgetTypographyTitle => 'تایپوگرافی';

  @override
  String get widgetTypographyBody =>
      'تایپوگرافی ویجت با سبک برنامه (Cinzel + Manrope) در هر دو iOS و اندروید هماهنگ است.';

  @override
  String get language => 'زبان';

  @override
  String get hijriMuharram => 'محرّم';

  @override
  String get hijriSafar => 'صفر';

  @override
  String get hijriRabiAwwal => 'ربیع‌الاول';

  @override
  String get hijriRabiThani => 'ربیع‌الثانی';

  @override
  String get hijriJumadaAwwal => 'جمادی‌الاول';

  @override
  String get hijriJumadaThani => 'جمادی‌الثانی';

  @override
  String get hijriRajab => 'رجب';

  @override
  String get hijriShaaban => 'شعبان';

  @override
  String get hijriRamadan => 'رمضان';

  @override
  String get hijriShawwal => 'شوال';

  @override
  String get hijriDhuAlQadah => 'ذوالقعده';

  @override
  String get hijriDhuAlHijjah => 'ذوالحجه';

  @override
  String hijriDateFormat(String day, String month, String year) {
    return '$day $month $year هـ.ق';
  }

  @override
  String get eidAlFitr => 'نماز عید فطر';

  @override
  String get eidAlAdha => 'نماز عید قربان';

  @override
  String get qibla => 'قبله';

  @override
  String get towardsTheQibla => 'جهت قبله';

  @override
  String get compassNotAvailable => 'حسگر قطب‌نما در این دستگاه موجود نیست.';

  @override
  String get locationRequiredForQibla =>
      'برای تعیین جهت قبله به موقعیت مکانی نیاز است.';
}
