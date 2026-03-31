# iOS Widget Setup (Home + Lock Screen)

Bu projede Flutter tarafi ve widget Swift dosyalari hazirlandi. Xcode tarafinda bir kez target eklemesi yapman gerekiyor.

## Hazir dosyalar
- `ios/PrayerWidgetExtension/PrayerWidgetBundle.swift`
- `ios/PrayerWidgetExtension/PrayerWidget.swift`
- `ios/PrayerWidgetExtension/Info.plist`
- `ios/PrayerWidgetExtension/PrayerWidgetExtension.entitlements`
- `ios/Runner/Runner.entitlements`

## Xcode adimlari
1. `ios/Runner.xcworkspace` ac.
2. `File > New > Target... > Widget Extension` sec.
3. Product Name: `PrayerWidgetExtension` (veya istedigin isim).
4. "Include Configuration Intent" kapali olsun.
5. Olustuktan sonra otomatik gelen widget swift dosyalarini sil.
6. Target'in `Build Settings > Info.plist File` degerini su dosyaya yonlendir:
   - `PrayerWidgetExtension/Info.plist`
7. `Build Settings > Product Bundle Identifier`:
   - `com.osmyildiz.digitalminaret.PrayerWidgetExtension`
8. `Build Settings > Code Signing Entitlements`:
   - `PrayerWidgetExtension/PrayerWidgetExtension.entitlements`
9. `Signing & Capabilities`:
   - App ve widget target'larina `App Groups` ekle.
   - Her ikisinde de: `group.com.osmyildiz.digitalminaret`
10. Widget target'in `Compile Sources` listesine ekle:
   - `PrayerWidgetBundle.swift`
   - `PrayerWidget.swift`

## Flutter baglantisi
Flutter tarafinda `WidgetService` App Group ve widget update ismini su sekilde kullanir:
- App Group: `group.com.osmyildiz.digitalminaret`
- iOS widget kind: `PrayerWidget`

Bu nedenle Swift tarafinda `WidgetConstants.widgetKind = "PrayerWidget"` olarak kalmali.

## Test
1. Flutter uygulamayi cihazda ac.
2. Prayer times hesaplandiktan sonra widget verisi yazilir.
3. Ana ekranda ve lock screen'de widget ekleyip kontrol et.
