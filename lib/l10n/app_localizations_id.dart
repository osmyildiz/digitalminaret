// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Digital Minaret';

  @override
  String get prayerFajr => 'Subuh';

  @override
  String get prayerSunrise => 'Terbit';

  @override
  String get prayerDhuhr => 'Dzuhur';

  @override
  String get prayerAsr => 'Ashar';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isya';

  @override
  String get prayerJumuah => 'Jumat';

  @override
  String get prayerIftar => 'Buka Puasa';

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
  String get suhoorEnds => 'SAHUR BERAKHIR';

  @override
  String get iftarTime => 'WAKTU BUKA PUASA';

  @override
  String get unknown => 'Tidak diketahui';

  @override
  String get welcome => 'Selamat Datang';

  @override
  String get welcomeSubtitle =>
      'Atur lokasi, metode perhitungan, dan mazhab untuk memulai dengan jadwal sholat yang akurat.';

  @override
  String get continueButton => 'Lanjutkan';

  @override
  String get close => 'Tutup';

  @override
  String get ok => 'OK';

  @override
  String get notNow => 'Nanti Saja';

  @override
  String get submit => 'Kirim';

  @override
  String get cancel => 'Batal';

  @override
  String get download => 'Unduh';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get settings => 'Pengaturan';

  @override
  String get stepLocation => '1. Lokasi';

  @override
  String get useCurrentLocation => 'Gunakan Lokasi Saat Ini';

  @override
  String get enterLocation => 'Masukkan Lokasi';

  @override
  String get searchLocation => 'Cari Lokasi';

  @override
  String get cityOrAddress => 'Kota atau alamat';

  @override
  String get noLocationSelected => 'Lokasi belum dipilih';

  @override
  String locationSetTo(String cityName) {
    return 'Lokasi diatur ke $cityName. Jadwal sholat diperbarui.';
  }

  @override
  String get locationUpdated =>
      'Lokasi diperbarui dan jadwal sholat disegarkan.';

  @override
  String get unableToGetLocation =>
      'Tidak dapat memperoleh lokasi. Coba cari secara manual.';

  @override
  String get stepCalculationMethod => '2. Metode Perhitungan';

  @override
  String get stepAsrMadhab => '3. Mazhab Ashar';

  @override
  String get stepFullAdhanPack => '4. Paket Adzan Lengkap';

  @override
  String get adhanPackNote =>
      'Adzan notifikasi tetap 30 detik. Pilihan ini digunakan untuk adzan lengkap saat Anda mengetuk notifikasi.';

  @override
  String get methodIsna => 'Amerika Utara (ISNA)';

  @override
  String get methodMuslimWorldLeague => 'Rabithah Alam Islami';

  @override
  String get methodTurkeyDiyanet => 'Türkiye Diyanet';

  @override
  String get methodEgyptian => 'Mesir';

  @override
  String get methodKarachi => 'Karachi (UISC)';

  @override
  String get methodUmmAlQura => 'Umm al-Qura (Mekah)';

  @override
  String get methodDubai => 'Dubai (Wilayah Teluk)';

  @override
  String get methodSingapore => 'Singapura / Asia Tenggara';

  @override
  String get methodTehran => 'Teheran (Iran)';

  @override
  String get madhabNonHanafi => 'Non-Hanafi';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get asrMadhab => 'Mazhab Ashar';

  @override
  String get location => 'Lokasi';

  @override
  String get calculation => 'Perhitungan';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get adhanAudio => 'Audio Adzan';

  @override
  String get supportAndTrust => 'Dukungan & Kepercayaan';

  @override
  String get permissionNeeded => 'Izin Diperlukan';

  @override
  String get pleaseAllowNotifications =>
      'Silakan izinkan notifikasi di Pengaturan iPhone.';

  @override
  String get fullAdhanOnNotificationTap =>
      'Adzan lengkap saat mengetuk notifikasi';

  @override
  String get playDuaAfterAdhan => 'Putar doa setelah adzan';

  @override
  String adhanPackLabel(String packName) {
    return 'Paket Adzan: $packName';
  }

  @override
  String get adhanPacks => 'Paket Adzan';

  @override
  String get downloadAdhanPack => 'Unduh Paket Adzan';

  @override
  String adhanPackDownloadPrompt(String packName) {
    return '$packName akan diunduh ke perangkat Anda. Lanjutkan?';
  }

  @override
  String get downloadingAdhanPack => 'Mengunduh paket adzan...';

  @override
  String downloadFailed(String error) {
    return 'Unduhan gagal: $error';
  }

  @override
  String packDownloaded(String packName) {
    return '$packName telah diunduh.';
  }

  @override
  String get donate => 'Donasi';

  @override
  String get donateSubtitle => 'Dukung pengembangan jika Anda berkenan.';

  @override
  String get sendFeedback => 'Kirim Masukan';

  @override
  String get sendFeedbackSubtitle => 'Buka formulir singkat';

  @override
  String get widgetSetup => 'Pengaturan Widget';

  @override
  String get widgetSetupSubtitle =>
      'Cara menambahkan dan menyegarkan widget layar utama.';

  @override
  String get privacyNotes => 'Catatan Privasi';

  @override
  String get privacyNotesSubtitle =>
      'Baca bagaimana data ditangani di perangkat.';

  @override
  String get thankYouForUsing =>
      'Terima kasih telah menggunakan Digital Minaret.';

  @override
  String get appAlwaysFree =>
      'Aplikasi ini akan selalu bebas iklan dan gratis digunakan.';

  @override
  String get rateDigitalMinaret => 'Beri Nilai Digital Minaret';

  @override
  String get ratePromptMessage =>
      'Apakah Anda menikmati perjalanan spiritual ini? Masukan Anda membantu kami menerangi jalan.';

  @override
  String get couldNotOpenLink => 'Tidak dapat membuka tautan di perangkat ini.';

  @override
  String couldNotPlayPreview(String error) {
    return 'Tidak dapat memutar pratinjau adzan: $error';
  }

  @override
  String notificationsCouldNotBeScheduled(String error) {
    return 'Notifikasi tidak dapat dijadwalkan sepenuhnya: $error';
  }

  @override
  String couldNotContinue(String error) {
    return 'Tidak dapat melanjutkan. Silakan coba lagi. ($error)';
  }

  @override
  String get hadithOfTheDay => 'Hadis Hari Ini';

  @override
  String get ramadanDua => 'Doa Ramadan';

  @override
  String get verseFromQuran => 'Ayat dari Al-Quran';

  @override
  String get hadithBody =>
      'Bulan Ramadan telah datang kepada kalian, bulan yang penuh berkah di mana Allah mewajibkan kalian berpuasa. (Nasa\'i)';

  @override
  String get duaBody =>
      'Ya Allah, aku memohon kepada-Mu cinta-Mu, dan cinta orang-orang yang mencintai-Mu, dan amalan-amalan yang mendekatkanku kepada cinta-Mu.';

  @override
  String get verseBody =>
      'Wahai orang-orang yang beriman, diwajibkan atas kamu berpuasa sebagaimana diwajibkan atas orang-orang sebelum kamu agar kamu bertakwa. (Al-Baqarah 2:183)';

  @override
  String get supportTheApp => 'Dukung Aplikasi';

  @override
  String get donateDescription =>
      'Aplikasi ini gratis dan bebas iklan. Jika berkenan, Anda dapat mendukung pengembangan dengan donasi sekali.';

  @override
  String get purchaseDidNotComplete => 'Pembelian tidak selesai.';

  @override
  String get thankYou => 'Terima Kasih';

  @override
  String get thankYouDonateMessage =>
      'Dukungan Anda sangat berarti. Ini membantu menjaga aplikasi tetap gratis dan bebas iklan.';

  @override
  String get smallTip => 'Donasi Kecil';

  @override
  String get mediumTip => 'Donasi Sedang';

  @override
  String get largeTip => 'Donasi Besar';

  @override
  String get donationOptionsUnavailable => 'Opsi donasi belum tersedia.';

  @override
  String get donationOptionsSetup =>
      'Tambahkan kunci RevenueCat dan produk toko (tip_small, tip_medium, tip_large), lalu coba lagi.';

  @override
  String get feedbackSubject => 'Masukan untuk Digital Minaret';

  @override
  String get mailCouldNotBeOpened => 'Aplikasi email tidak dapat dibuka.';

  @override
  String get openMailApp => 'Buka Aplikasi Email';

  @override
  String get subject => 'Subjek';

  @override
  String get yourFeedback => 'Masukan Anda';

  @override
  String get feedbackHint =>
      'Ini akan membuka aplikasi email bawaan Anda dengan kolom yang sudah terisi.';

  @override
  String get privacyNoAccountRequired => 'Tidak perlu akun';

  @override
  String get privacyNoAccountBody =>
      'Anda dapat menggunakan aplikasi tanpa membuat akun atau membagikan data profil pribadi.';

  @override
  String get privacyLocationOnDevice => 'Lokasi tetap di perangkat';

  @override
  String get privacyLocationBody =>
      'Lokasi hanya digunakan untuk menghitung jadwal sholat dan disimpan secara lokal di ponsel Anda.';

  @override
  String get privacyNoAds => 'Tanpa iklan, tanpa pelacak';

  @override
  String get privacyNoAdsBody =>
      'Aplikasi ini tidak memiliki SDK iklan dan tidak ada pelacakan analitik secara bawaan.';

  @override
  String get privacyNotificationsLocal => 'Notifikasi bersifat lokal';

  @override
  String get privacyNotificationsBody =>
      'Notifikasi sholat dijadwalkan dan dipicu langsung di perangkat.';

  @override
  String get privacyFeedbackOptIn => 'Masukan bersifat opsional';

  @override
  String get privacyFeedbackBody =>
      'Jika Anda mengetuk masukan, aplikasi email bawaan Anda akan terbuka. Tidak ada yang dikirim secara otomatis.';

  @override
  String get widgetSetupTitle => 'Pengaturan Widget';

  @override
  String get widgetLiveTitle => 'Widget Langsung';

  @override
  String get widgetLiveBody =>
      'Widget menampilkan sholat saat ini, sholat berikutnya, dan waktu tersisa. Data diperbarui saat aplikasi menghitung/menyinkronkan jadwal sholat, dan lini masa disegarkan setiap menit.';

  @override
  String get widgetIosTitle => 'iOS';

  @override
  String get widgetIosBody =>
      'Tekan lama Layar Utama > + > Digital Minaret > pilih ukuran > Tambah Widget.\nJika tidak muncul setelah pembaruan: hapus widget, buka aplikasi sekali, lalu tambahkan kembali.';

  @override
  String get widgetAndroidTitle => 'Android';

  @override
  String get widgetAndroidBody =>
      'Tekan lama Layar Utama > Widget > Digital Minaret.\nJika tidak diperbarui: hapus/tambahkan kembali widget dan buka aplikasi sekali untuk mengirim waktu terbaru.';

  @override
  String get widgetTypographyTitle => 'Tipografi';

  @override
  String get widgetTypographyBody =>
      'Tipografi widget diselaraskan dengan gaya aplikasi (Cinzel + Manrope) di iOS maupun Android.';

  @override
  String get language => 'Bahasa';

  @override
  String get hijriMuharram => 'Muharram';

  @override
  String get hijriSafar => 'Safar';

  @override
  String get hijriRabiAwwal => 'Rabiul Awal';

  @override
  String get hijriRabiThani => 'Rabiul Akhir';

  @override
  String get hijriJumadaAwwal => 'Jumadil Awal';

  @override
  String get hijriJumadaThani => 'Jumadil Akhir';

  @override
  String get hijriRajab => 'Rajab';

  @override
  String get hijriShaaban => 'Syakban';

  @override
  String get hijriRamadan => 'Ramadhan';

  @override
  String get hijriShawwal => 'Syawal';

  @override
  String get hijriDhuAlQadah => 'Dzulkaidah';

  @override
  String get hijriDhuAlHijjah => 'Dzulhijjah';

  @override
  String hijriDateFormat(String day, String month, String year) {
    return '$day $month $year H';
  }

  @override
  String get eidAlFitr => 'Shalat Idul Fitri';

  @override
  String get eidAlAdha => 'Shalat Idul Adha';

  @override
  String get qibla => 'Kiblat';

  @override
  String get towardsTheQibla => 'ARAH KIBLAT';

  @override
  String get compassNotAvailable =>
      'Sensor kompas tidak tersedia di perangkat ini.';

  @override
  String get locationRequiredForQibla =>
      'Lokasi diperlukan untuk menentukan arah kiblat.';
}
