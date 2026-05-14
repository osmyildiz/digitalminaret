import SwiftUI

@main
struct DigitalMinaretWatchApp: App {
    @StateObject private var store = PrayerStore()

    var body: some Scene {
        WindowGroup {
            PrayerWatchView()
                .environmentObject(store)
                .onAppear { store.reload() }
        }
    }
}
