import WidgetKit
import SwiftUI

@main
struct PrayerWidgetBundle: WidgetBundle {
    var body: some Widget {
        PrayerWidget()
        if #available(iOS 16.1, *) {
            PrayerLiveActivity()
        }
    }
}
