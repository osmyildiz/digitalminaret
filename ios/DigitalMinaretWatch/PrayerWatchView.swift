import SwiftUI

private enum WatchTheme {
    static let gold = Color(red: 1.0, green: 0.88, blue: 0.62)
    static let navy = Color(red: 5/255, green: 12/255, blue: 30/255)
    static let muted = Color.white.opacity(0.55)
    static let warn = Color(red: 1.0, green: 0.65, blue: 0.32)
    static let urgent = Color(red: 0.91, green: 0.35, blue: 0.35)
}

struct PrayerWatchView: View {
    @EnvironmentObject var store: PrayerStore

    var body: some View {
        TabView {
            heroView
                .tag(0)
            listView
                .tag(1)
        }
        .tabViewStyle(.page)
        .background(WatchTheme.navy)
    }

    private var heroView: some View {
        VStack(spacing: 6) {
            Text(store.activePrayer.uppercased())
                .font(.custom("Cinzel", size: 16).weight(.bold))
                .foregroundColor(WatchTheme.gold)
                .lineLimit(1)

            Text(timeString(store.activePrayerTime))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)

            countdownView

            Text("→ \(store.nextPrayer.uppercased())")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(WatchTheme.muted)

            Text(store.location)
                .font(.system(size: 10))
                .foregroundColor(WatchTheme.muted)
                .lineLimit(1)
        }
        .padding(.horizontal, 6)
    }

    @ViewBuilder
    private var countdownView: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { context in
            let remaining = max(0, store.nextPrayerTime.timeIntervalSince(context.date))
            let color: Color = {
                if remaining < 5 * 60 { return WatchTheme.urgent }
                if remaining < 15 * 60 { return WatchTheme.warn }
                return WatchTheme.gold
            }()

            Text(formatRemaining(remaining))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(color)
                .shadow(color: color.opacity(0.4), radius: 6)
        }
    }

    private var listView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(store.prayers.enumerated()), id: \.offset) { _, item in
                    let active = item.0.caseInsensitiveCompare(store.activePrayer) == .orderedSame
                    HStack {
                        Text(item.0.uppercased())
                            .font(.system(size: 12, weight: active ? .bold : .medium))
                            .foregroundColor(active ? WatchTheme.gold : WatchTheme.muted)
                        Spacer()
                        Text(timeString(item.1))
                            .font(.system(size: 12, weight: active ? .bold : .medium))
                            .monospacedDigit()
                            .foregroundColor(active ? .white : WatchTheme.muted)
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(.horizontal, 8)
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func formatRemaining(_ seconds: TimeInterval) -> String {
        let s = Int(seconds)
        let h = s / 3600
        let m = (s % 3600) / 60
        let sec = s % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, sec)
        }
        return String(format: "%02d:%02d", m, sec)
    }
}
