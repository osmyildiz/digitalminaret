# Apple Watch — Digital Minaret Watch App

Bu klasor saat uygulamasinin Swift kodlarini icerir. Xcode'da target eklemen gerekiyor (Flutter projesi Apple Watch target'i tek basina yonetemiyor).

## Hazir dosyalar
- `DigitalMinaretWatchApp.swift` — @main giris noktasi
- `PrayerStore.swift` — App Group UserDefaults'tan veri okuyan observable model
- `PrayerWatchView.swift` — SwiftUI ekranlari (hero + liste)
- `Info.plist`
- `DigitalMinaretWatch.entitlements` — App Group iznine sahip

## Xcode kurulum adimlari (tek seferlik)

1. `ios/Runner.xcworkspace` ac.
2. `File > New > Target...` → **watchOS** sekmesi → **App** sec.
3. Product Name: `DigitalMinaretWatch`
4. Interface: **SwiftUI**, Language: **Swift**
5. **"Include Notifications Scene"** — kapali birakabilirsin (iPhone bildirimleri otomatik forward edilir)
6. **"Embed in Companion App"** — `Runner` sec
7. Target olusturulduktan sonra:
   - Xcode'un urettigi default `ContentView.swift`, `*App.swift` dosyalarini sil.
   - Bu klasordeki dosyalari **target'a ekle**: sag tik → "Add Files to..." → `DigitalMinaretWatch` target'ini sec.
8. Build Settings:
   - `Info.plist File`: `DigitalMinaretWatch/Info.plist`
   - `Code Signing Entitlements`: `DigitalMinaretWatch/DigitalMinaretWatch.entitlements`
   - `Product Bundle Identifier`: `com.osmyildiz.digitalminaret.watchkitapp` (saat app id'leri companion app id ile eslesmek zorunda)
9. **Signing & Capabilities**:
   - `App Groups` capability ekle
   - `group.com.osmyildiz.digitalminaret` kontrolu yap
10. **Companion app (Runner) tarafinda**:
    - `Build Settings > WKCompanionAppBundleIdentifier` → `com.osmyildiz.digitalminaret`

## Fontlar
Cinzel ve Manrope `UIAppFonts` icinde tanimli. Bu fontlarin watch target'a kopyalanmasi gerekiyor:
1. `ios/PrayerWidgetExtension/Fonts/Cinzel-Variable.ttf` ve `Manrope-Variable.ttf` dosyalarini `DigitalMinaretWatch` target'ina ekle.
2. "Copy Bundle Resources" build phase'inde gorunduklerini dogrula.

Eger font eklenmezse SwiftUI default sistem fontuna duser, app yine calisir ama gorsel olarak iPhone uygulamasiyla bicimleri uyusmaz.

## Veri akisi

Saat uygulamasi **kendi prayer hesaplamasini yapmaz**. iPhone tarafinda Flutter `WidgetService` `group.com.osmyildiz.digitalminaret` App Group'una su anahtarlari yazar:
- `location_name`
- `prayer_{fajr,sunrise,dhuhr,asr,maghrib,isha}_epoch_ms`
- `prayer_{key}_name` (yerellestirilmis isimler)

`PrayerStore` her 60 saniyede bir bu anahtarlari yeniden okur. iPhone uygulamasi acilip prayer times hesaplaninca veriler taze tutulur.

## Sinirlar — bilmen gerekenler

- **iPhone bildirimleri otomatik forward edilir**: saat uygulamasinda ek kod gerekmiyor. iPhone Adhan bildirim'i geldiginde saat de titreyip gostercek.
- **Complications**: bu scaffold complication eklemiyor. WatchOS 10+ icin `WidgetKit` ile complication yazilabilir, ayri bir Widget target'i gerekiyor.
- **Bagimsiz internet**: gerekirse `WatchConnectivity` ile telefon olmadan da prayer time istegi yapilabilir; bu scaffold App Group'a guvendigi icin telefon en az gunde bir ag baglantili olmali.
- **Cinzel font watchOS render performansi**: bazi saat modellerinde custom font biraz yavas yuklenir. Sorun yasarsan `font(.custom("Cinzel"...))` cagrilarini `.font(.system(...))` ile degistir.

## Test
1. Apple Watch'u iPhone ile esle.
2. iPhone'da uygulamayi ac, prayer times hesaplansin.
3. Saat uygulamasini ac → vakit, countdown ve liste gorunmeli.
4. Saat 60 saniyede bir kendini yeniler.
