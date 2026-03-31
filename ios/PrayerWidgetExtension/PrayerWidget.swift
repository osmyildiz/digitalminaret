import WidgetKit
import SwiftUI

private enum WidgetConstants {
    static let appGroupId = "group.com.osmyildiz.digitalminaret"
    static let widgetKind = "PrayerWidget"
}

private struct WidgetTheme {
    static let gold = Color(red: 1.0, green: 0.88, blue: 0.62)
    static let goldDeep = Color(red: 0.72, green: 0.42, blue: 0.12)
    static let navyTop = Color(red: 2/255, green: 3/255, blue: 10/255)
    static let navyBottom = Color(red: 7/255, green: 19/255, blue: 48/255)
    static let text = Color.white
    static let muted = Color.white.opacity(0.72)
}

private enum WidgetTypography {
    static func heading(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        Font.custom("Cinzel", size: size).weight(weight)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        Font.custom("Manrope", size: size).weight(weight)
    }
}

struct PrayerEntry: TimelineEntry {
    let date: Date
    let activePrayer: String
    let activePrayerTime: Date
    let nextPrayer: String
    let nextPrayerTime: Date
    let periodStart: Date
    let periodEnd: Date
    let location: String
    let prayers: [(String, Date)]
}

struct PrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(
            date: Date(),
            activePrayer: "Dhuhr",
            activePrayerTime: Date(),
            nextPrayer: "Asr",
            nextPrayerTime: Date().addingTimeInterval(5 * 3600),
            periodStart: Date(),
            periodEnd: Date().addingTimeInterval(5 * 3600),
            location: "Selkirk",
            prayers: [
                ("Fajr", Date()),
                ("Sunrise", Date().addingTimeInterval(3600)),
                ("Dhuhr", Date().addingTimeInterval(2 * 3600)),
                ("Asr", Date().addingTimeInterval(5 * 3600)),
                ("Maghrib", Date().addingTimeInterval(8 * 3600)),
                ("Isha", Date().addingTimeInterval(10 * 3600)),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date().addingTimeInterval(60)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func loadEntry() -> PrayerEntry {
        guard let defaults = UserDefaults(suiteName: WidgetConstants.appGroupId) else {
            return PrayerEntry(
                date: Date(),
                activePrayer: "Dhuhr",
                activePrayerTime: Date(),
                nextPrayer: "Asr",
                nextPrayerTime: Date().addingTimeInterval(5 * 3600),
                periodStart: Date(),
                periodEnd: Date().addingTimeInterval(5 * 3600),
                location: "Selkirk",
                prayers: [
                    ("Fajr", Date()),
                    ("Sunrise", Date().addingTimeInterval(3600)),
                    ("Dhuhr", Date().addingTimeInterval(2 * 3600)),
                    ("Asr", Date().addingTimeInterval(5 * 3600)),
                    ("Maghrib", Date().addingTimeInterval(8 * 3600)),
                    ("Isha", Date().addingTimeInterval(10 * 3600)),
                ]
            )
        }

        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let location = defaults.string(forKey: "location_name") ?? "Selkirk"

        let keys = ["fajr", "sunrise", "dhuhr", "asr", "maghrib", "isha"]
        let rawPrayers: [(String, Date)] = keys.compactMap { key in
            guard let date = readDate(
                defaults: defaults,
                epochKey: "prayer_\(key)_epoch_ms",
                stringKey: "prayer_\(key)",
                parser: parser
            ) else {
                return nil
            }
            let localizedName = defaults.string(forKey: "prayer_\(key)_name") ?? key.capitalized
            return (localizedName, date)
        }

        // Rebase prayer times to today so widget keeps moving even when app is closed.
        // Stored absolute timestamps can be from a previous day.
        let prayers = rebasedToToday(rawPrayers)
        let now = Date()
        let state = resolveWidgetState(now: now, prayers: prayers)

        return PrayerEntry(
            date: now,
            activePrayer: state.activePrayer,
            activePrayerTime: state.activePrayerTime,
            nextPrayer: state.nextPrayer,
            nextPrayerTime: state.nextPrayerTime,
            periodStart: state.periodStart,
            periodEnd: state.periodEnd,
            location: location,
            prayers: prayers
        )
    }

    private func rebasedToToday(_ prayers: [(String, Date)]) -> [(String, Date)] {
        let cal = Calendar.current
        let today = Date()
        return prayers.compactMap { item in
            let hm = cal.dateComponents([.hour, .minute, .second], from: item.1)
            guard let rebased = cal.date(
                bySettingHour: hm.hour ?? 0,
                minute: hm.minute ?? 0,
                second: hm.second ?? 0,
                of: today
            ) else {
                return nil
            }
            return (item.0, rebased)
        }
        .sorted { $0.1 < $1.1 }
    }

    private func resolveWidgetState(
        now: Date,
        prayers: [(String, Date)]
    ) -> (
        activePrayer: String,
        activePrayerTime: Date,
        nextPrayer: String,
        nextPrayerTime: Date,
        periodStart: Date,
        periodEnd: Date
    ) {
        guard !prayers.isEmpty else {
            let next = now.addingTimeInterval(3600)
            return (
                activePrayer: "Isha",
                activePrayerTime: now,
                nextPrayer: "Fajr",
                nextPrayerTime: next,
                periodStart: now,
                periodEnd: next
            )
        }

        var previous = prayers.last!
        var next = prayers.first!
        for item in prayers {
            if item.1 <= now {
                previous = item
            } else {
                next = item
                break
            }
        }

        // After last prayer, next is tomorrow's first prayer.
        if next.1 <= now {
            next = (next.0, next.1.addingTimeInterval(24 * 3600))
        }

        // Before first prayer, previous is yesterday's last prayer.
        if previous.1 > now {
            previous = (previous.0, previous.1.addingTimeInterval(-24 * 3600))
        }

        return (
            activePrayer: previous.0,
            activePrayerTime: previous.1,
            nextPrayer: next.0,
            nextPrayerTime: next.1,
            periodStart: previous.1,
            periodEnd: next.1
        )
    }

    private func readDate(
        defaults: UserDefaults,
        epochKey: String,
        stringKey: String?,
        parser: ISO8601DateFormatter
    ) -> Date? {
        if let ms = defaults.object(forKey: epochKey) as? NSNumber {
            return Date(timeIntervalSince1970: ms.doubleValue / 1000.0)
        }
        guard let key = stringKey,
              let raw = defaults.string(forKey: key),
              !raw.isEmpty else {
            return nil
        }
        if let iso = parser.date(from: raw) {
            return iso
        }
        let fallback = DateFormatter()
        fallback.locale = Locale(identifier: "en_US_POSIX")
        fallback.timeZone = TimeZone.current
        fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return fallback.date(from: raw)
    }
}

struct PrayerWidgetView: View {
    let entry: PrayerProvider.Entry
    @Environment(\.widgetFamily) private var family

    private var progress: Double {
        let total = entry.periodEnd.timeIntervalSince(entry.periodStart)
        if total <= 0 { return 0 }
        let elapsed = Date().timeIntervalSince(entry.periodStart)
        return min(max(elapsed / total, 0), 1)
    }

    private var timeRemainingText: String {
        let remaining = max(0, entry.nextPrayerTime.timeIntervalSince(Date()))
        let h = Int(remaining) / 3600
        let m = (Int(remaining) % 3600) / 60
        return String(format: "%02dh %02dm", h, m)
    }

    var body: some View {
        switch family {
        case .systemMedium:
            medium2x4
        case .systemLarge:
            homeHero4x4
        case .systemExtraLarge:
            timeline3x4
        case .systemSmall:
            smallCompact
        case .accessoryInline:
            Text("\(entry.activePrayer): \(timeString(entry.activePrayerTime))")
        case .accessoryCircular:
            VStack(spacing: 2) {
                Text(entry.activePrayer.prefix(3).uppercased())
                    .font(WidgetTypography.body(10, weight: .bold))
                Text(timeString(entry.activePrayerTime))
                    .font(WidgetTypography.body(9, weight: .semibold))
            }
            .foregroundColor(WidgetTheme.gold)
        case .accessoryRectangular:
            HStack {
                Text(entry.activePrayer.uppercased())
                    .font(WidgetTypography.heading(12, weight: .bold))
                Spacer()
                Text(timeString(entry.activePrayerTime))
                    .font(WidgetTypography.body(12, weight: .bold))
            }
            .foregroundColor(WidgetTheme.gold)
        @unknown default:
            medium2x4
        }
    }

    // 1) 2x4 - horizontal with all 5 prayers
    private var medium2x4: some View {
        HStack(spacing: 10) {
            // Left: active prayer info
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.activePrayer.uppercased())
                    .font(WidgetTypography.heading(20, weight: .bold))
                    .minimumScaleFactor(0.72)
                    .lineLimit(1)
                    .foregroundColor(WidgetTheme.gold)

                Text(timeString(entry.activePrayerTime))
                    .font(WidgetTypography.body(26, weight: .bold))
                    .minimumScaleFactor(0.72)
                    .lineLimit(1)
                    .foregroundColor(WidgetTheme.text)

                ThinProgress(progress: progress)

                Text(timeRemainingText)
                    .font(WidgetTypography.body(11, weight: .semibold))
                    .foregroundColor(WidgetTheme.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: compact 5 prayer list
            VStack(alignment: .trailing, spacing: 3) {
                ForEach(Array(entry.prayers.filter { !isSunrise($0.0) }.enumerated()), id: \.offset) { _, item in
                    let isActive = item.0.caseInsensitiveCompare(entry.activePrayer) == .orderedSame
                    HStack(spacing: 6) {
                        Text(item.0.prefix(5).uppercased())
                            .font(WidgetTypography.body(isActive ? 12 : 10, weight: isActive ? .bold : .medium))
                            .foregroundColor(isActive ? WidgetTheme.gold : WidgetTheme.muted)
                            .lineLimit(1)
                        Text(timeString(item.1))
                            .font(WidgetTypography.body(isActive ? 12 : 10, weight: isActive ? .bold : .medium))
                            .foregroundColor(isActive ? WidgetTheme.text : WidgetTheme.muted)
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .widgetShell
    }

    // 2) 3x4 concept - vertical timeline on large widget
    private var timeline3x4: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.location)
                    .font(WidgetTypography.body(13, weight: .semibold))
                    .foregroundColor(WidgetTheme.muted)
                Spacer()
                Text(hijriDateText())
                    .font(WidgetTypography.body(13, weight: .semibold))
                    .foregroundColor(WidgetTheme.muted)
            }

            VStack(spacing: 10) {
                ForEach(Array(entry.prayers.enumerated()), id: \.offset) { _, item in
                    let isActive = item.0.caseInsensitiveCompare(entry.activePrayer) == .orderedSame
                    HStack(spacing: 10) {
                        Circle()
                            .fill(isActive ? WidgetTheme.gold : Color.white.opacity(0.28))
                            .frame(width: isActive ? 10 : 7, height: isActive ? 10 : 7)
                            .shadow(color: isActive ? WidgetTheme.gold.opacity(0.55) : .clear, radius: 6)

                        Text(item.0.uppercased())
                            .font(WidgetTypography.heading(isActive ? 18 : 14, weight: isActive ? .bold : .semibold))
                            .foregroundColor(isActive ? WidgetTheme.gold : WidgetTheme.muted)

                        Spacer()

                        Text(timeString(item.1))
                            .font(WidgetTypography.body(isActive ? 18 : 14, weight: isActive ? .bold : .semibold))
                            .foregroundColor(isActive ? WidgetTheme.text : WidgetTheme.muted)
                    }
                }
            }

            ThinProgress(progress: progress)
        }
        .padding(16)
        .widgetShell
    }

    // 3) 4x4 hero + 5 prayer times on iPhone home screen (systemLarge)
    private var homeHero4x4: some View {
        VStack(spacing: 6) {
            // Active prayer header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(arabicName(entry.activePrayer))
                        .font(WidgetTypography.heading(32, weight: .bold))
                        .foregroundColor(WidgetTheme.gold)
                    Text(entry.activePrayer.uppercased())
                        .font(WidgetTypography.heading(22, weight: .bold))
                        .foregroundColor(WidgetTheme.gold)
                        .shadow(color: WidgetTheme.gold.opacity(0.45), radius: 8)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(timeString(entry.activePrayerTime))
                        .font(WidgetTypography.body(28, weight: .bold))
                        .foregroundColor(WidgetTheme.text)
                    Text(timeRemainingText)
                        .font(WidgetTypography.body(13, weight: .semibold))
                        .foregroundColor(WidgetTheme.muted)
                }
            }

            ThinProgress(progress: progress)
                .padding(.vertical, 4)

            // All 5 prayer times (skip sunrise)
            ForEach(Array(entry.prayers.filter { !isSunrise($0.0) }.enumerated()), id: \.offset) { _, item in
                let isActive = item.0.caseInsensitiveCompare(entry.activePrayer) == .orderedSame
                HStack {
                    Text(item.0.uppercased())
                        .font(WidgetTypography.heading(isActive ? 16 : 13, weight: isActive ? .bold : .semibold))
                        .foregroundColor(isActive ? WidgetTheme.gold : WidgetTheme.muted)
                    Spacer()
                    Text(timeString(item.1))
                        .font(WidgetTypography.body(isActive ? 16 : 13, weight: isActive ? .bold : .semibold))
                        .foregroundColor(isActive ? WidgetTheme.text : WidgetTheme.muted)
                }
                .padding(.vertical, 2)
            }

            Spacer(minLength: 2)

            // Location
            Text(entry.location)
                .font(WidgetTypography.body(11, weight: .semibold))
                .foregroundColor(WidgetTheme.muted.opacity(0.7))
        }
        .padding(16)
        .homeHeroShell
    }

    private func isSunrise(_ name: String) -> Bool {
        let lower = name.lowercased()
        return lower == "sunrise" || lower == "güneş" || lower == "شروق"
            || lower == "الشروق" || lower == "terbit" || lower == "chourouk"
            || lower == "طلوع آفتاب"
    }

    private var smallCompact: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.activePrayer.uppercased())
                .font(WidgetTypography.heading(20, weight: .bold))
                .foregroundColor(WidgetTheme.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(timeString(entry.activePrayerTime))
                .font(WidgetTypography.body(28, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .foregroundColor(WidgetTheme.text)

            ThinProgress(progress: progress)

            Text("\(entry.nextPrayer) \(timeString(entry.nextPrayerTime))")
                .font(WidgetTypography.body(12, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundColor(WidgetTheme.muted)
        }
        .padding(14)
        .widgetShell
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func nextDisplayLabel() -> String {
        return entry.nextPrayer.uppercased()
    }

    private func arabicName(_ prayer: String) -> String {
        // Arabic names are stored per-key in UserDefaults by Flutter.
        // Fall back to a static map for the original English names.
        let staticMap: [String: String] = [
            "fajr": "فجر", "sabah": "فجر",
            "sunrise": "شروق", "güneş": "شروق", "terbit": "شروق", "chourouk": "شروق",
            "dhuhr": "ظهر", "öğle": "ظهر", "dzuhur": "ظهر", "dohr": "ظهر",
            "asr": "عصر", "ikindi": "عصر", "ashar": "عصر",
            "maghrib": "مغرب", "akşam": "مغرب",
            "isha": "عشاء", "yatsı": "عشاء", "isya": "عشاء",
            "الفجر": "فجر", "الشروق": "شروق", "الظهر": "ظهر",
            "العصر": "عصر", "المغرب": "مغرب", "العشاء": "عشاء",
            "subuh": "فجر",
        ]
        return staticMap[prayer.lowercased()] ?? prayer
    }

    private func hijriDateText() -> String {
        let calendar = Calendar(identifier: .islamicUmmAlQura)
        let comps = calendar.dateComponents([.day, .month], from: Date())
        let monthNames = [
            "Muharram", "Safar", "Rabi I", "Rabi II", "Jumada I", "Jumada II",
            "Rajab", "Shaban", "Ramadan", "Shawwal", "Dhu al-Qadah", "Dhu al-Hijjah",
        ]
        let month = monthNames[max(0, min(11, (comps.month ?? 1) - 1))]
        return "\(comps.day ?? 1) \(month)"
    }
}

private struct ThinProgress: View {
    let progress: Double

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.17))
                .frame(height: 6)
            GeometryReader { geo in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [WidgetTheme.gold, WidgetTheme.goldDeep],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, geo.size.width * CGFloat(min(max(progress, 0), 1))), height: 6)
                    .shadow(color: WidgetTheme.gold.opacity(0.5), radius: 5)
            }
        }
        .frame(height: 6)
    }
}

private struct HeroProgress: View {
    let progress: Double
    let label: String

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(height: 18)

            GeometryReader { geo in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [WidgetTheme.gold, WidgetTheme.goldDeep],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(18, geo.size.width * CGFloat(min(max(progress, 0), 1))), height: 18)
                    .shadow(color: WidgetTheme.gold.opacity(0.5), radius: 8)
            }

            Text(label)
                .font(WidgetTypography.body(18, weight: .bold))
                .foregroundColor(Color.white.opacity(0.92))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 18)
    }
}

private extension View {
    var widgetShell: some View {
        ZStack {
            LinearGradient(
                colors: [WidgetTheme.navyTop, WidgetTheme.navyBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                RadialGradient(
                    colors: [WidgetTheme.gold.opacity(0.22), .clear],
                    center: .topTrailing,
                    startRadius: 8,
                    endRadius: 210
                )
            )
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 120)
                    .blur(radius: 16)
                    .opacity(0.6)
            )

            self
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(WidgetTheme.gold.opacity(0.22), lineWidth: 1)
        )
        .containerBackground(.clear, for: .widget)
    }
}

private extension View {
    var homeHeroShell: some View {
        ZStack {
            LinearGradient(
                colors: [WidgetTheme.navyTop, WidgetTheme.navyBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.34),
                            Color.white.opacity(0.07),
                            .clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 180)
                .blur(radius: 18)

            self
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(WidgetTheme.gold.opacity(0.2), lineWidth: 1)
        )
        .containerBackground(.clear, for: .widget)
    }
}

struct PrayerWidget: Widget {
    let kind: String = WidgetConstants.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            PrayerWidgetView(entry: entry)
        }
        .configurationDisplayName("Digital Minaret")
        .description("Premium prayer timeline and next prayer info.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}
