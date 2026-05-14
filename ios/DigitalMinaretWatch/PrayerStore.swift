import Foundation
import Combine

// PrayerStore reads from the shared App Group UserDefaults that the
// iPhone app populates via Flutter's WidgetService. The watch does
// not request network data or compute prayer times itself; it mirrors
// whatever the phone last wrote.
@MainActor
final class PrayerStore: ObservableObject {
    @Published var location: String = "—"
    @Published var activePrayer: String = "—"
    @Published var activePrayerTime: Date = Date()
    @Published var nextPrayer: String = "—"
    @Published var nextPrayerTime: Date = Date().addingTimeInterval(3600)
    @Published var prayers: [(String, Date)] = []

    private let appGroupId = "group.com.osmyildiz.digitalminaret"
    private var refreshTimer: Timer?

    init() {
        startRefreshTimer()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    private func startRefreshTimer() {
        // App Group writes from iPhone are not push-notified to watchOS,
        // so we poll every 60 s while the watch app is foreground.
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.reload()
            }
        }
    }

    func reload() {
        guard let defaults = UserDefaults(suiteName: appGroupId) else { return }

        location = defaults.string(forKey: "location_name") ?? "—"

        let keys = ["fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha"]
        let raw: [(String, Date)] = keys.compactMap { key in
            let epoch = defaults.double(forKey: "prayer_\(key)_epoch_ms")
            if epoch <= 0 { return nil }
            let name = defaults.string(forKey: "prayer_\(key)_name")
                ?? key.capitalized
            return (name, Date(timeIntervalSince1970: epoch / 1000.0))
        }

        prayers = rebaseToToday(raw).sorted { $0.1 < $1.1 }

        let now = Date()
        var previous = prayers.last
        var next = prayers.first
        for item in prayers {
            if item.1 <= now {
                previous = item
            } else {
                next = item
                break
            }
        }

        if let p = previous {
            activePrayer = p.0
            activePrayerTime = p.1 > now ? p.1.addingTimeInterval(-86_400) : p.1
        }
        if let n = next {
            nextPrayer = n.0
            nextPrayerTime = n.1 <= now ? n.1.addingTimeInterval(86_400) : n.1
        }
    }

    private func rebaseToToday(_ items: [(String, Date)]) -> [(String, Date)] {
        let cal = Calendar.current
        let today = Date()
        return items.compactMap { item in
            let hm = cal.dateComponents([.hour, .minute, .second], from: item.1)
            guard let rebased = cal.date(
                bySettingHour: hm.hour ?? 0,
                minute: hm.minute ?? 0,
                second: hm.second ?? 0,
                of: today
            ) else { return nil }
            return (item.0, rebased)
        }
    }
}
