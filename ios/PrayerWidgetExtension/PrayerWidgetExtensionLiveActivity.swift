import ActivityKit
import WidgetKit
import SwiftUI

// Note: PrayerActivityAttributes is defined in ios/Shared/PrayerActivityAttributes.swift
// and must be a member of BOTH Runner and PrayerWidgetExtension targets.

private enum LATheme {
    static let gold = Color(red: 1.0, green: 0.88, blue: 0.62)
    static let goldDeep = Color(red: 0.72, green: 0.42, blue: 0.12)
    static let navyTop = Color(red: 2/255, green: 3/255, blue: 10/255)
    static let navyBottom = Color(red: 7/255, green: 19/255, blue: 48/255)
    static let warn = Color(red: 1.0, green: 0.65, blue: 0.32)
    static let urgent = Color(red: 0.91, green: 0.35, blue: 0.35)
}

@available(iOS 16.1, *)
struct PrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            // Lock-screen / banner UI
            LockScreenView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.001))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.activePrayer.uppercased())
                            .font(.caption2.weight(.bold))
                            .foregroundColor(LATheme.gold)
                        Text(formatTime(context.state.activePrayerTime))
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.nextPrayer.uppercased())
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.white.opacity(0.7))
                        Text(
                            timerInterval: Date()...context.state.nextPrayerTime,
                            countsDown: true,
                            showsHours: true
                        )
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(LATheme.gold)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.location)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.55))
                }
            } compactLeading: {
                Text(context.state.activePrayer.prefix(3).uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundColor(LATheme.gold)
            } compactTrailing: {
                Text(
                    timerInterval: Date()...context.state.nextPrayerTime,
                    countsDown: true,
                    showsHours: false
                )
                .monospacedDigit()
                .font(.caption2.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: 50)
            } minimal: {
                Text(context.state.activePrayer.prefix(1).uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundColor(LATheme.gold)
            }
        }
    }
}

@available(iOS 16.1, *)
private struct LockScreenView: View {
    let state: PrayerActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 14) {
            // Left: arabic + english name
            VStack(alignment: .leading, spacing: 4) {
                Text(state.activePrayerArabic)
                    .font(.custom("Cinzel", size: 24).weight(.bold))
                    .foregroundColor(LATheme.gold)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Text(state.activePrayer.uppercased())
                    .font(.custom("Cinzel", size: 13).weight(.bold))
                    .foregroundColor(LATheme.gold.opacity(0.85))
                    .lineLimit(1)
                Text(state.location)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: countdown + next prayer label
            VStack(alignment: .trailing, spacing: 2) {
                Text(state.nextPrayer.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                Text(
                    timerInterval: Date()...state.nextPrayerTime,
                    countsDown: true,
                    showsHours: true
                )
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(LATheme.gold)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

                Text(formatTime(state.nextPrayerTime))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [LATheme.navyTop, LATheme.navyBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: date)
}
