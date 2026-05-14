# iOS Widget Setup (Home + Lock Screen + Live Activity)

Bu projede Flutter tarafi ve widget Swift dosyalari hazirlandi. Xcode tarafinda bir kez target eklemesi yapman gerekiyor.

## Hazir dosyalar
- `ios/PrayerWidgetExtension/PrayerWidgetBundle.swift`
- `ios/PrayerWidgetExtension/PrayerWidget.swift`
- `ios/PrayerWidgetExtension/PrayerWidgetExtensionLiveActivity.swift`
- `ios/PrayerWidgetExtension/Info.plist`
- `ios/PrayerWidgetExtension/PrayerWidgetExtension.entitlements`
- `ios/Runner/Runner.entitlements`
- `ios/Runner/AppDelegate.swift` (MethodChannel bridge)
- `ios/Shared/PrayerActivityAttributes.swift` (paylasilan struct)

## Xcode adimlari — Widget target (ilk kurulumda)
1. `ios/Runner.xcworkspace` ac.
2. `File > New > Target... > Widget Extension` sec.
3. Product Name: `PrayerWidgetExtension` (veya istedigin isim).
4. **"Include Live Activity"** seceneji isaretle.
5. "Include Configuration Intent" kapali olsun.
6. Olustuktan sonra otomatik gelen widget swift dosyalarini sil.
7. Target'in `Build Settings > Info.plist File` degerini su dosyaya yonlendir:
   - `PrayerWidgetExtension/Info.plist`
8. `Build Settings > Product Bundle Identifier`:
   - `com.osmyildiz.digitalminaret.PrayerWidgetExtension`
9. `Build Settings > Code Signing Entitlements`:
   - `PrayerWidgetExtension/PrayerWidgetExtension.entitlements`
10. `Signing & Capabilities`:
    - App ve widget target'larina `App Groups` ekle.
    - Her ikisinde de: `group.com.osmyildiz.digitalminaret`
11. Widget target'in `Compile Sources` listesine ekle:
    - `PrayerWidgetBundle.swift`
    - `PrayerWidget.swift`
    - `PrayerWidgetExtensionLiveActivity.swift`
    - `../Shared/PrayerActivityAttributes.swift` (asagida acikladim)

## Live Activity — paylasilan dosya kurulumu (KRITIK)

`PrayerActivityAttributes` struct'i Runner ile widget extension arasinda
**ayni Swift tipi** olmak zorunda. Aksi halde ActivityKit start/update
isteklerini widget bulamaz. Tek dogru yol: dosyayi her iki target'a uye
yapmak.

1. Xcode'da sol panelde dosyayi bul: `ios/Shared/PrayerActivityAttributes.swift`
   - Eger gorunmuyorsa: `Project navigator > sag tik > Add Files to "Runner"...`
     ile dosyayi ekle.
2. Dosyayi sec.
3. Sag panelden **File Inspector** ac (cmd+opt+1).
4. **Target Membership** bolumunde su iki kutucugu isaretle:
   - [x] Runner
   - [x] PrayerWidgetExtension

Eger bu adim atlanirsa derlemede "Cannot find 'PrayerActivityAttributes'
in scope" hatasi alirsin.

## Info.plist — Live Activity izni
`ios/Runner/Info.plist` icine zaten su iki anahtar eklendi:
- `NSSupportsLiveActivities = true`
- `NSSupportsLiveActivitiesFrequentUpdates = true`

Eklenmemis ise Live Activity baslamaz.

## Flutter baglantisi
Flutter tarafinda `WidgetService` App Group ve widget update ismini su sekilde kullanir:
- App Group: `group.com.osmyildiz.digitalminaret`
- iOS widget kind: `PrayerWidget`
- Live Activity method channel: `com.osmyildiz.digitalminaret/live_activity`

Bu nedenle Swift tarafinda `WidgetConstants.widgetKind = "PrayerWidget"` olarak kalmali.

`LiveActivityService` ios platformunda otomatik calisir, diger platformlarda no-op'tur.
Activity baslatma zamani: prayer times yeniden hesaplaninca (WidgetService.updateWidget icinden tetiklenir).

## Test
1. Flutter uygulamayi gercek bir cihazda ac (simulator'de Live Activity goremezsin — sadece Dynamic Island shortcut'lar Xcode 15+ simulator'inde calisir).
2. Prayer times hesaplandiktan sonra widget verisi yazilir.
3. Home screen widget'ini ekle, lock screen widget'ini ekle (lock screen > kart sec > Digital Minaret).
4. iOS 16.1+ cihazda Live Activity otomatik basliyor olmali — lock screen'de banner halinde gorunecek.
5. iPhone 14 Pro / 15 / 16 Pro'da Dynamic Island da otomatik gorunecek.
