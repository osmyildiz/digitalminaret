# Wear OS — Digital Minaret Watch

Bu modul Compose for Wear ile yazilmis ayri bir Android uygulama. Flutter `app` modulu PHONE'da kalir, `wear` modulu paired Wear OS cihazina yuklenir.

## Hazir dosyalar
- `wear/build.gradle.kts` — Compose for Wear bagimliliklari
- `wear/src/main/AndroidManifest.xml`
- `wear/src/main/java/.../MainActivity.kt` — entry activity
- `wear/src/main/java/.../PrayerWatchScreen.kt` — Compose UI
- `wear/src/main/java/.../PrayerRepository.kt` — DataLayer + SharedPreferences cache
- `wear/src/main/java/.../PrayerDataListenerService.kt` — Wearable push receiver
- `android/settings.gradle.kts` — include(":wear") eklendi

## Telefon tarafi (zaten hazir)
- `app/build.gradle.kts` icine `play-services-wearable` eklendi
- `WearDataPusher.kt` — telefon `PutDataMapRequest` ile push eder
- `MainActivity.kt` — Flutter'in cagiracagi `com.osmyildiz.digitalminaret/wear` channel'i kayitli
- Flutter `WearSyncService` widget guncellemesi sirasinda otomatik push eder

## Build / yukleme adimlari
1. `flutter build apk` veya `flutter run` — `app` modulu olusur (phone APK).
2. Wear modulunu ayrica build et:
   ```bash
   cd android
   ./gradlew :wear:assembleDebug
   ```
3. Olusan APK: `android/wear/build/outputs/apk/debug/wear-debug.apk`
4. Wear OS emulator veya gercek cihaza yukle:
   ```bash
   adb -s <wear-device-id> install android/wear/build/outputs/apk/debug/wear-debug.apk
   ```
5. **`com.google.android.wearable.standalone = false`** Manifest'te tanimli — telefon olmadan calismaz. Eger bagimsiz saat uygulamasi istersen bunu `true` yap ve PrayerRepository icine network-tabanli prayer-time API entegrasyonu ekle.

## Test akisi
1. Wear OS emulator'u baslat (Android Studio > Device Manager > Wear OS).
2. Telefon emulator'u ile pair et:
   ```
   adb -s <wear-emulator-id> forward tcp:5601 tcp:5601
   ```
   Sonra phone'da Wear OS companion uygulamasini ac, "Pair with emulator" sec.
3. Phone uygulamasini calistir, prayer times hesaplansin.
4. `WidgetService.updateWidget` cagrildiginda Wear push otomatik yapilir.
5. Saat uygulamasini ac → vakit ve countdown gozukmeli.

## Sinirlar — bilmen gerekenler
- **Compose for Wear hala beta-ish**: bazi animasyonlar bazi saat modellerinde takilir.
- **DataLayer push 100KB siniri**: prayer payload ~500 byte oldugundan sorun yok.
- **Battery**: 30 saniyede bir refresh (`PrayerRepository.startRefreshLoop`) — saat uygulamasi forground iken; arka planda Android Doze devreye girer.
- **Companion APK**: saat APK'si Play Console'a "Wear OS application linked to phone app" olarak yuklenir. iOS'taki gibi otomatik embed degildir, ayri bir publish surecidir.
- **Complications eklenmedi**: bu scaffold sadece launchable app. Saat kadraninda complication gostermek icin `ComplicationDataSourceService` subclass'i ve `xml/watch_face_complication.xml` eklemek gerek.
- **Flutter direkt Wear OS'a deploy edilemez**: Flutter framework su anki halinde Wear OS'u desteklemiyor. Bu yuzden module saf Kotlin/Compose ile yazildi.

## Sonraki iyilestirmeler (gelecek surumler icin)
- Complication (kadran uzeri kucuk widget) ekle
- Ambient mode (always-on display) optimize et
- Tile (saat tile listesi) ekle — `androidx.wear.tiles`
- Bagimsiz mode + network tabanli prayer times
