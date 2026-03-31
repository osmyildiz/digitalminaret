// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Digital Minaret';

  @override
  String get prayerFajr => 'Sabah';

  @override
  String get prayerSunrise => 'Güneş';

  @override
  String get prayerDhuhr => 'Öğle';

  @override
  String get prayerAsr => 'İkindi';

  @override
  String get prayerMaghrib => 'Akşam';

  @override
  String get prayerIsha => 'Yatsı';

  @override
  String get prayerJumuah => 'Cuma';

  @override
  String get prayerIftar => 'İftar';

  @override
  String get prayerSuhoor => 'Sahur';

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
  String get suhoorEnds => 'SAHUR BİTİŞİ';

  @override
  String get iftarTime => 'İFTAR VAKTİ';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String get welcome => 'Hoş Geldiniz';

  @override
  String get welcomeSubtitle =>
      'Doğru namaz vakitleri için konum, hesaplama yöntemi ve mezhep ayarlarını yapın.';

  @override
  String get continueButton => 'Devam';

  @override
  String get close => 'Kapat';

  @override
  String get ok => 'Tamam';

  @override
  String get notNow => 'Şimdi Değil';

  @override
  String get submit => 'Gönder';

  @override
  String get cancel => 'İptal';

  @override
  String get download => 'İndir';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get settings => 'Ayarlar';

  @override
  String get stepLocation => '1. Konum';

  @override
  String get useCurrentLocation => 'Mevcut Konumu Kullan';

  @override
  String get enterLocation => 'Konum Girin';

  @override
  String get searchLocation => 'Konum Ara';

  @override
  String get cityOrAddress => 'Şehir veya adres';

  @override
  String get noLocationSelected => 'Konum seçilmedi';

  @override
  String locationSetTo(String cityName) {
    return 'Konum $cityName olarak ayarlandı. Namaz vakitleri güncellendi.';
  }

  @override
  String get locationUpdated =>
      'Konum güncellendi ve namaz vakitleri yenilendi.';

  @override
  String get unableToGetLocation => 'Konum alınamadı. Manuel aramayı deneyin.';

  @override
  String get stepCalculationMethod => '2. Hesaplama Yöntemi';

  @override
  String get stepAsrMadhab => '3. İkindi Mezhebi';

  @override
  String get stepFullAdhanPack => '4. Tam Ezan Paketi';

  @override
  String get adhanPackNote =>
      'Bildirim ezanı 30 saniye olarak sabitlenmiştir. Bu seçim, bildirime dokunduğunuzda çalınacak tam ezan içindir.';

  @override
  String get methodIsna => 'Kuzey Amerika (ISNA)';

  @override
  String get methodMuslimWorldLeague => 'İslam Dünyası Birliği';

  @override
  String get methodTurkeyDiyanet => 'Türkiye Diyanet';

  @override
  String get methodEgyptian => 'Mısır';

  @override
  String get methodKarachi => 'Karachi (UISC)';

  @override
  String get methodUmmAlQura => 'Ümmü\'l-Kura (Mekke)';

  @override
  String get methodDubai => 'Dubai (Körfez Bölgesi)';

  @override
  String get methodSingapore => 'Singapur / Güneydoğu Asya';

  @override
  String get methodTehran => 'Tahran (İran)';

  @override
  String get madhabNonHanafi => 'Hanefi Dışı';

  @override
  String get madhabHanafi => 'Hanefi';

  @override
  String get asrMadhab => 'İkindi Mezhebi';

  @override
  String get location => 'Konum';

  @override
  String get calculation => 'Hesaplama';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get adhanAudio => 'Ezan Sesi';

  @override
  String get supportAndTrust => 'Destek ve Güven';

  @override
  String get permissionNeeded => 'İzin Gerekli';

  @override
  String get pleaseAllowNotifications =>
      'Lütfen iPhone Ayarlarından bildirimlere izin verin.';

  @override
  String get fullAdhanOnNotificationTap => 'Bildirime dokunulduğunda tam ezan';

  @override
  String get playDuaAfterAdhan => 'Ezandan sonra dua çal';

  @override
  String adhanPackLabel(String packName) {
    return 'Ezan Paketi: $packName';
  }

  @override
  String get adhanPacks => 'Ezan Paketleri';

  @override
  String get downloadAdhanPack => 'Ezan Paketi İndir';

  @override
  String adhanPackDownloadPrompt(String packName) {
    return '$packName cihazınıza indirilecek. Devam edilsin mi?';
  }

  @override
  String get downloadingAdhanPack => 'Ezan paketi indiriliyor...';

  @override
  String downloadFailed(String error) {
    return 'İndirme başarısız: $error';
  }

  @override
  String packDownloaded(String packName) {
    return '$packName indirildi.';
  }

  @override
  String get donate => 'Bağış Yap';

  @override
  String get donateSubtitle => 'Dilerseniz geliştirmeyi destekleyin.';

  @override
  String get sendFeedback => 'Geri Bildirim Gönder';

  @override
  String get sendFeedbackSubtitle => 'Hızlı bir form açın';

  @override
  String get widgetSetup => 'Widget Kurulumu';

  @override
  String get widgetSetupSubtitle =>
      'Ana ekran widget\'ını nasıl ekleyip güncelleyeceğinizi öğrenin.';

  @override
  String get privacyNotes => 'Gizlilik Notları';

  @override
  String get privacyNotesSubtitle =>
      'Verilerin cihazda nasıl işlendiğini okuyun.';

  @override
  String get thankYouForUsing =>
      'Digital Minaret\'i kullandığınız için teşekkür ederiz.';

  @override
  String get appAlwaysFree =>
      'Bu uygulama her zaman reklamsız ve ücretsiz kalacaktır.';

  @override
  String get rateDigitalMinaret => 'Digital Minaret\'i Değerlendirin';

  @override
  String get ratePromptMessage =>
      'Manevi yolculuğunuzdan memnun musunuz? Geri bildiriminiz yolumuzu aydınlatmamıza yardımcı olur.';

  @override
  String get couldNotOpenLink => 'Bu cihazda bağlantı açılamadı.';

  @override
  String couldNotPlayPreview(String error) {
    return 'Ezan önizlemesi oynatılamadı: $error';
  }

  @override
  String notificationsCouldNotBeScheduled(String error) {
    return 'Bildirimler tam olarak planlanamadı: $error';
  }

  @override
  String couldNotContinue(String error) {
    return 'Devam edilemedi. Lütfen tekrar deneyin. ($error)';
  }

  @override
  String get hadithOfTheDay => 'Günün Hadisi';

  @override
  String get ramadanDua => 'Ramazan Duası';

  @override
  String get verseFromQuran => 'Kur\'an\'dan Ayet';

  @override
  String get hadithBody =>
      'Ramazan ayı geldi; Allah\'ın oruç tutmanızı farz kıldığı mübarek bir aydır. (Nesâî)';

  @override
  String get duaBody =>
      'Allah\'ım, Sen\'in sevgini, Seni sevenlerin sevgisini ve beni Senin sevgine yaklaştıracak amelleri nasip etmeni istiyorum.';

  @override
  String get verseBody =>
      'Ey iman edenler! Oruç, sizden öncekilere farz kılındığı gibi, sakınmanız için size de farz kılındı. (Bakara 2:183)';

  @override
  String get supportTheApp => 'Uygulamayı Destekle';

  @override
  String get donateDescription =>
      'Bu uygulama ücretsiz ve reklamsızdır. Dilerseniz geliştirmeyi tek seferlik bir bağışla destekleyebilirsiniz.';

  @override
  String get purchaseDidNotComplete => 'Satın alma tamamlanamadı.';

  @override
  String get thankYou => 'Teşekkürler';

  @override
  String get thankYouDonateMessage =>
      'Desteğiniz bizim için çok değerli. Uygulamanın ücretsiz ve reklamsız kalmasına yardımcı oluyor.';

  @override
  String get smallTip => 'Küçük Bağış';

  @override
  String get mediumTip => 'Orta Bağış';

  @override
  String get largeTip => 'Büyük Bağış';

  @override
  String get donationOptionsUnavailable =>
      'Bağış seçenekleri henüz kullanılabilir değil.';

  @override
  String get donationOptionsSetup =>
      'RevenueCat anahtarlarını ve mağaza ürünlerini (tip_small, tip_medium, tip_large) ekleyip tekrar deneyin.';

  @override
  String get feedbackSubject => 'Digital Minaret Geri Bildirimi';

  @override
  String get mailCouldNotBeOpened => 'E-posta uygulaması açılamadı.';

  @override
  String get openMailApp => 'E-posta Uygulamasını Aç';

  @override
  String get subject => 'Konu';

  @override
  String get yourFeedback => 'Geri bildiriminiz';

  @override
  String get feedbackHint =>
      'Bu, varsayılan e-posta uygulamanızı önceden doldurulmuş alanlarla açar.';

  @override
  String get privacyNoAccountRequired => 'Hesap gerekmez';

  @override
  String get privacyNoAccountBody =>
      'Uygulamayı hesap oluşturmadan veya kişisel veri paylaşmadan kullanabilirsiniz.';

  @override
  String get privacyLocationOnDevice => 'Konum cihazda kalır';

  @override
  String get privacyLocationBody =>
      'Konum yalnızca namaz vakitlerini hesaplamak için kullanılır ve telefonunuzda yerel olarak saklanır.';

  @override
  String get privacyNoAds => 'Reklam yok, izleyici yok';

  @override
  String get privacyNoAdsBody =>
      'Uygulamada reklam SDK\'sı ve varsayılan olarak analitik takibi bulunmamaktadır.';

  @override
  String get privacyNotificationsLocal => 'Bildirimler yereldir';

  @override
  String get privacyNotificationsBody =>
      'Namaz bildirimleri doğrudan cihazda planlanır ve tetiklenir.';

  @override
  String get privacyFeedbackOptIn => 'Geri bildirim isteğe bağlıdır';

  @override
  String get privacyFeedbackBody =>
      'Geri bildirime dokunursanız varsayılan e-posta uygulamanız açılır. Otomatik olarak hiçbir şey gönderilmez.';

  @override
  String get widgetSetupTitle => 'Widget Kurulumu';

  @override
  String get widgetLiveTitle => 'Canlı Widget';

  @override
  String get widgetLiveBody =>
      'Widget mevcut namazı, sonraki namazı ve kalan süreyi gösterir. Veriler uygulama namaz vakitlerini hesapladığında güncellenir ve zaman çizelgesi her dakika yenilenir.';

  @override
  String get widgetIosTitle => 'iOS';

  @override
  String get widgetIosBody =>
      'Ana Ekrana uzun basın > + > Digital Minaret > boyut seçin > Widget Ekle.\nGüncelleme sonrası görünmüyorsa: widget\'ı kaldırın, uygulamayı bir kez açın, sonra tekrar ekleyin.';

  @override
  String get widgetAndroidTitle => 'Android';

  @override
  String get widgetAndroidBody =>
      'Ana Ekrana uzun basın > Widget\'lar > Digital Minaret.\nEskiyse: widget\'ı kaldırıp tekrar ekleyin ve güncel vakitleri göndermek için uygulamayı bir kez açın.';

  @override
  String get widgetTypographyTitle => 'Tipografi';

  @override
  String get widgetTypographyBody =>
      'Widget tipografisi hem iOS hem de Android\'de uygulama stiliyle (Cinzel + Manrope) uyumludur.';

  @override
  String get language => 'Dil';

  @override
  String get hijriMuharram => 'Muharrem';

  @override
  String get hijriSafar => 'Safer';

  @override
  String get hijriRabiAwwal => 'Rebiülevvel';

  @override
  String get hijriRabiThani => 'Rebiülahir';

  @override
  String get hijriJumadaAwwal => 'Cemaziyelevvel';

  @override
  String get hijriJumadaThani => 'Cemaziyelahir';

  @override
  String get hijriRajab => 'Recep';

  @override
  String get hijriShaaban => 'Şaban';

  @override
  String get hijriRamadan => 'Ramazan';

  @override
  String get hijriShawwal => 'Şevval';

  @override
  String get hijriDhuAlQadah => 'Zilkade';

  @override
  String get hijriDhuAlHijjah => 'Zilhicce';

  @override
  String hijriDateFormat(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get eidAlFitr => 'Ramazan Bayramı Namazı';

  @override
  String get eidAlAdha => 'Kurban Bayramı Namazı';

  @override
  String get qibla => 'Kıble';

  @override
  String get towardsTheQibla => 'KIBLE YONU';

  @override
  String get compassNotAvailable => 'Bu cihazda pusula sensoru bulunmuyor.';

  @override
  String get locationRequiredForQibla =>
      'Kible yonunu belirlemek icin konum gereklidir.';
}
