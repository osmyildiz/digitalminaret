import Foundation
import ActivityKit

// IMPORTANT: This file must be a member of BOTH targets:
//   - Runner (the host app — starts/updates the activity)
//   - PrayerWidgetExtension (the widget — renders the activity)
//
// In Xcode: select this file → File Inspector → Target Membership →
// tick both Runner and PrayerWidgetExtension.
//
// Live Activities key the activity type by its full Swift type identity
// (module + name). Duplicating the struct in two modules produces two
// different types and start/update from the app will not be visible to
// the widget extension.

@available(iOS 16.1, *)
public struct PrayerActivityAttributes: ActivityAttributes {
    /// One stop on the day timeline (e.g. Fajr / Sunrise / … / Isha).
    public struct PrayerStop: Codable, Hashable {
        public var name: String   // localized short label, e.g. "Sabah"
        public var time: Date

        public init(name: String, time: Date) {
            self.name = name
            self.time = time
        }
    }

    public struct ContentState: Codable, Hashable {
        public var activePrayer: String
        public var activePrayerArabic: String
        public var activePrayerTime: Date
        public var nextPrayer: String
        public var nextPrayerTime: Date
        public var location: String
        /// Full ordered day schedule (Fajr → Isha) used to draw the
        /// proportional timeline. Empty falls back to active→next only.
        public var schedule: [PrayerStop]

        public init(
            activePrayer: String,
            activePrayerArabic: String,
            activePrayerTime: Date,
            nextPrayer: String,
            nextPrayerTime: Date,
            location: String,
            schedule: [PrayerStop] = []
        ) {
            self.activePrayer = activePrayer
            self.activePrayerArabic = activePrayerArabic
            self.activePrayerTime = activePrayerTime
            self.nextPrayer = nextPrayer
            self.nextPrayerTime = nextPrayerTime
            self.location = location
            self.schedule = schedule
        }
    }

    public var widgetKind: String

    public init(widgetKind: String) {
        self.widgetKind = widgetKind
    }
}
