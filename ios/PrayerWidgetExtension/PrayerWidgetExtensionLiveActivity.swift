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

/// Day-vs-night colour palette switching based on the active prayer.
/// During Maghrib/Isha/Fajr the arc reads as "night"; during Sunrise/
/// Dhuhr/Asr it reads as "day". The completed segment in both modes
/// is the same warm gold accent — only the BACKGROUND ring and the
/// banner gradient shift.
@available(iOS 16.1, *)
private struct PhasePalette {
    let bannerTop: Color
    let bannerBottom: Color
    let trackColor: Color
    let accent: Color

    static let day = PhasePalette(
        bannerTop: Color(red: 0.08, green: 0.18, blue: 0.40),
        bannerBottom: Color(red: 0.06, green: 0.12, blue: 0.30),
        trackColor: Color.white.opacity(0.30),
        accent: Color(red: 1.0, green: 0.88, blue: 0.62)
    )
    static let night = PhasePalette(
        bannerTop: Color(red: 0.04, green: 0.06, blue: 0.18),
        bannerBottom: Color(red: 0.02, green: 0.03, blue: 0.10),
        trackColor: Color(red: 0.52, green: 0.58, blue: 0.85).opacity(0.45),
        accent: Color(red: 1.0, green: 0.88, blue: 0.62)
    )

    static func resolve(for arabic: String) -> PhasePalette {
        let nightKeys = ["مغرب", "عشاء", "فجر"]
        for k in nightKeys where arabic.contains(k) {
            return .night
        }
        return .day
    }
}

@available(iOS 16.1, *)
private struct LockScreenView: View {
    let state: PrayerActivityAttributes.ContentState

    /// Derives the upcoming prayer from the full schedule + current
    /// time, instead of trusting the static nextPrayer fields. This is
    /// what makes the activity self-advance to the next prayer the
    /// moment one passes — even while the phone is locked and the app
    /// can't push an update. (iOS re-renders the Live Activity
    /// periodically; on the next render the schedule lookup returns the
    /// new target so the countdown flips automatically.)
    private func currentNext()
        -> (name: String, time: Date) {
        let now = Date()
        let stops = state.schedule.sorted { $0.time < $1.time }
        if let upcoming = stops.first(where: { $0.time > now }) {
            return (upcoming.name, upcoming.time)
        }
        // Past the last prayer (Isha) → tomorrow's first (Fajr +1d).
        if let first = stops.first {
            return (first.name,
                    first.time.addingTimeInterval(86_400))
        }
        // No schedule → fall back to the static fields.
        return (state.nextPrayer, state.nextPrayerTime)
    }

    var body: some View {
        let palette = PhasePalette.resolve(for: state.activePrayerArabic)
        let nextUp = currentNext()

        ZStack {
            LinearGradient(
                colors: [palette.bannerTop, palette.bannerBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                // Brand row — real app icon + name.
                HStack(spacing: 6) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .clipShape(RoundedRectangle(cornerRadius: 4,
                                                    style: .continuous))
                    Text("Digital Minaret")
                        .font(.custom("Cinzel", size: 11).weight(.bold))
                        .foregroundColor(.white.opacity(0.85))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer(minLength: 8)

                // Full-day proportional timeline: prayer names above
                // their nodes, segment lengths = real time gaps,
                // elapsed = thick bright white, remaining = faint white.
                DayTimelineView(
                    schedule: state.schedule,
                    activeTime: state.activePrayerTime,
                    nextTime: state.nextPrayerTime,
                    palette: palette
                )
                .frame(height: 26)
                .padding(.horizontal, 18)
                .padding(.top, 6)

                Spacer(minLength: 8)

                // Big countdown to the next prayer (schedule-derived so
                // it flips automatically when a prayer time passes).
                Text("\(nextUp.name.uppercased()) • \(formatTime(nextUp.time))")
                    .font(.custom("Cinzel", size: 12).weight(.bold))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                // showsHours:true → H:MM:SS like Athan Pro's "1:32:59".
                Text(
                    timerInterval: Date()...max(nextUp.time,
                                                Date().addingTimeInterval(1)),
                    countsDown: true,
                    showsHours: true
                )
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            }
        }
    }
}

/// Full-day timeline: every prayer is a node on a horizontal line,
/// the gap between two nodes is proportional to the real time between
/// those prayers. Elapsed portion (up to "now") is a thick bright
/// white line with filled nodes; the remaining portion is a faint
/// white line with hollow nodes. Prayer names sit above each node.
@available(iOS 16.1, *)
private struct DayTimelineView: View {
    let schedule: [PrayerActivityAttributes.PrayerStop]
    let activeTime: Date
    let nextTime: Date
    let palette: PhasePalette

    private struct Node {
        let name: String
        let x: CGFloat
        let passed: Bool
    }

    /// Picks the right set of stops to draw:
    ///   • Daytime  (Sunrise ≤ now < Isha) → Fajr…Isha
    ///   • Evening  (now ≥ Isha)           → Isha → Fajr(+1d) → Sunrise(+1d)
    ///   • Pre-dawn (now < Sunrise)        → Isha(-1d) → Fajr → Sunrise
    /// The night view collapses to the 3 points the user asked for and
    /// automatically flips back to the day view once Sunrise passes.
    private func resolvedStops() -> [PrayerActivityAttributes.PrayerStop] {
        let s = schedule.sorted { $0.time < $1.time }
        guard s.count >= 6 else { return s }
        let fajr = s[0], sunrise = s[1], isha = s[5]
        let now = Date()
        let day: TimeInterval = 86_400

        if now >= isha.time {
            return [
                isha,
                .init(name: fajr.name,
                      time: fajr.time.addingTimeInterval(day)),
                .init(name: sunrise.name,
                      time: sunrise.time.addingTimeInterval(day)),
            ]
        }
        if now < sunrise.time {
            return [
                .init(name: isha.name,
                      time: isha.time.addingTimeInterval(-day)),
                fajr,
                sunrise,
            ]
        }
        return s
    }

    /// Pre-computes node x-positions (ViewBuilder forbids local funcs).
    private func layout(in w: CGFloat)
        -> (nodes: [Node], usable: CGFloat, pad: CGFloat, nowX: CGFloat)? {
        let pad: CGFloat = 18
        let usable = max(1, w - pad * 2)
        let stops = resolvedStops()
        guard stops.count >= 2,
              let t0 = stops.first?.time,
              let tN = stops.last?.time,
              tN.timeIntervalSince(t0) > 0 else { return nil }

        let span = tN.timeIntervalSince(t0)
        let now = Date()
        let nodes: [Node] = stops.map { s in
            let f = max(0.0, min(1.0, s.time.timeIntervalSince(t0) / span))
            return Node(name: s.name,
                        x: pad + usable * CGFloat(f),
                        passed: s.time <= now)
        }
        let nf = max(0.0, min(1.0, now.timeIntervalSince(t0) / span))
        let nowX = pad + usable * CGFloat(nf)
        return (nodes, usable, pad, nowX)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let lineY = geo.size.height / 2

            if let lay = layout(in: w) {
                ZStack(alignment: .topLeading) {
                    // Faint full track (remaining).
                    Capsule()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: lay.usable, height: 3)
                        .position(x: w / 2, y: lineY)

                    // Bright elapsed track from start to now.
                    Capsule()
                        .fill(Color.white)
                        .frame(
                            width: max(0, min(lay.usable, lay.nowX - lay.pad)),
                            height: 4
                        )
                        .position(
                            x: lay.pad
                                + max(0, min(lay.usable, lay.nowX - lay.pad)) / 2,
                            y: lineY
                        )

                    // Nodes only — no labels (clean minimal timeline).
                    ForEach(0..<lay.nodes.count, id: \.self) { i in
                        let n = lay.nodes[i]
                        Circle()
                            .fill(n.passed ? Color.white
                                           : palette.bannerBottom)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle().stroke(
                                    n.passed ? Color.white
                                             : Color.white.opacity(0.5),
                                    lineWidth: 1.5
                                )
                            )
                            .position(x: n.x, y: lineY)
                    }

                    // Glowing "now" marker.
                    ZStack {
                        Circle()
                            .fill(palette.accent.opacity(0.55))
                            .frame(width: 22, height: 22)
                            .blur(radius: 6)
                        Circle()
                            .fill(palette.accent)
                            .frame(width: 11, height: 11)
                            .overlay(
                                Circle().stroke(.white, lineWidth: 1.4)
                            )
                    }
                    .position(x: lay.nowX, y: lineY)
                }
            } else {
                TimelineBarView(
                    activeTime: activeTime,
                    nextTime: nextTime,
                    palette: palette
                )
            }
        }
    }
}

/// Clean horizontal progress timeline (no arc, no icons): a rounded
/// capsule track with a bright "elapsed" fill, a passive faded-white
/// "remaining" segment, and a single glowing marker at the current
/// position. Reads instantly and renders perfectly in the Live
/// Activity's constrained height.
@available(iOS 16.1, *)
private struct TimelineBarView: View {
    let activeTime: Date
    let nextTime: Date
    let palette: PhasePalette

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let trackHeight: CGFloat = 6
            let y = h / 2
            let progress = CGFloat(currentProgress())
            let markerX = max(6, min(w - 6, w * progress))

            ZStack(alignment: .leading) {
                // Passive remaining track — faded solid white, full width.
                Capsule()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: w, height: trackHeight)
                    .position(x: w / 2, y: y)

                // Elapsed fill — bright, from start to the marker.
                Capsule()
                    .fill(Color.white)
                    .frame(width: markerX, height: trackHeight)
                    .position(x: markerX / 2, y: y)

                // Glowing marker dot at the current position.
                ZStack {
                    Circle()
                        .fill(palette.accent.opacity(0.55))
                        .frame(width: 26, height: 26)
                        .blur(radius: 7)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle().stroke(palette.accent, lineWidth: 1.4)
                        )
                }
                .position(x: markerX, y: y)
            }
        }
    }

    private func currentProgress() -> Double {
        let total = nextTime.timeIntervalSince(activeTime)
        guard total > 0 else { return 0 }
        let elapsed = Date().timeIntervalSince(activeTime)
        return max(0.0, min(1.0, elapsed / total))
    }
}

private func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: date)
}
