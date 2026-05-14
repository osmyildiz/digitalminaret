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
    public struct ContentState: Codable, Hashable {
        public var activePrayer: String
        public var activePrayerArabic: String
        public var activePrayerTime: Date
        public var nextPrayer: String
        public var nextPrayerTime: Date
        public var location: String

        public init(
            activePrayer: String,
            activePrayerArabic: String,
            activePrayerTime: Date,
            nextPrayer: String,
            nextPrayerTime: Date,
            location: String
        ) {
            self.activePrayer = activePrayer
            self.activePrayerArabic = activePrayerArabic
            self.activePrayerTime = activePrayerTime
            self.nextPrayer = nextPrayer
            self.nextPrayerTime = nextPrayerTime
            self.location = location
        }
    }

    public var widgetKind: String

    public init(widgetKind: String) {
        self.widgetKind = widgetKind
    }
}
