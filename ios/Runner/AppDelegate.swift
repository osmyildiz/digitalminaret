import Flutter
import UIKit
import flutter_local_notifications
import UserNotifications
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let pendingTapPayloadKey = "pending_notification_tap_payload_v1"
  private static let liveActivityChannelName = "com.osmyildiz.digitalminaret/live_activity"
  // Retained so ARC doesn't release the channel — FlutterMethodChannel
  // holds its handler weakly via the binary messenger.
  private static var retainedLiveActivityChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Implicit-engine pattern: this fires AFTER the Flutter engine is
  // created and BEFORE Dart code runs, which is the only window where
  // the binaryMessenger exists AND no Dart-side `MissingPluginException`
  // can be thrown yet. Registering the MethodChannel here closes the
  // race window we hit when binding inside didFinishLaunching (the root
  // view controller is nil at that point).
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DigitalMinaretLiveActivity") {
      registerLiveActivityChannel(messenger: registrar.messenger())
    }
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if let payload = response.notification.request.content.userInfo["payload"] as? String,
       !payload.isEmpty {
      let defaults = UserDefaults.standard
      defaults.set(payload, forKey: pendingTapPayloadKey)
      defaults.set(payload, forKey: "flutter.\(pendingTapPayloadKey)")
    }
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  // MARK: - Live Activity bridge

  private func registerLiveActivityChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: AppDelegate.liveActivityChannelName,
      binaryMessenger: messenger
    )
    Self.retainedLiveActivityChannel = channel

    channel.setMethodCallHandler { [weak self] call, result in
      guard #available(iOS 16.1, *) else {
        result(FlutterError(
          code: "UNSUPPORTED",
          message: "Live Activities require iOS 16.1+",
          details: nil
        ))
        return
      }
      switch call.method {
      case "isSupported":
        result(self?.liveActivitiesEnabled() ?? false)
      case "start":
        self?.startLiveActivity(arguments: call.arguments, result: result)
      case "update":
        self?.updateLiveActivity(arguments: call.arguments, result: result)
      case "end":
        self?.endLiveActivity(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @available(iOS 16.1, *)
  private func liveActivitiesEnabled() -> Bool {
    ActivityAuthorizationInfo().areActivitiesEnabled
  }

  @available(iOS 16.1, *)
  private func startLiveActivity(arguments: Any?, result: @escaping FlutterResult) {
    guard liveActivitiesEnabled() else {
      result(FlutterError(
        code: "PERMISSION_DENIED",
        message: "User disabled Live Activities for this app",
        details: nil
      ))
      return
    }
    guard let state = decodeContentState(arguments) else {
      result(FlutterError(code: "BAD_ARGS", message: "Invalid state payload", details: nil))
      return
    }

    let stale = nextPrayerDate(state)

    // If an activity already exists, update instead of creating a duplicate.
    if let existing = Activity<PrayerActivityAttributes>.activities.first {
      Task {
        if #available(iOS 16.2, *) {
          await existing.update(
            ActivityContent(state: state, staleDate: stale)
          )
        } else {
          await existing.update(using: state)
        }
        await MainActor.run { result(existing.id) }
      }
      return
    }

    do {
      let attrs = PrayerActivityAttributes(widgetKind: "PrayerLiveActivity")
      let activity: Activity<PrayerActivityAttributes>
      if #available(iOS 16.2, *) {
        activity = try Activity<PrayerActivityAttributes>.request(
          attributes: attrs,
          content: ActivityContent(state: state, staleDate: stale),
          pushType: nil
        )
      } else {
        activity = try Activity<PrayerActivityAttributes>.request(
          attributes: attrs,
          contentState: state,
          pushType: nil
        )
      }
      result(activity.id)
    } catch {
      result(FlutterError(
        code: "START_FAILED",
        message: "ActivityKit refused the request: \(error.localizedDescription)",
        details: nil
      ))
    }
  }

  @available(iOS 16.1, *)
  private func updateLiveActivity(arguments: Any?, result: @escaping FlutterResult) {
    guard let state = decodeContentState(arguments) else {
      result(FlutterError(code: "BAD_ARGS", message: "Invalid state payload", details: nil))
      return
    }
    let activities = Activity<PrayerActivityAttributes>.activities
    guard !activities.isEmpty else {
      result(false)
      return
    }
    let stale = nextPrayerDate(state)
    Task {
      for activity in activities {
        if #available(iOS 16.2, *) {
          await activity.update(
            ActivityContent(state: state, staleDate: stale)
          )
        } else {
          await activity.update(using: state)
        }
      }
      await MainActor.run { result(true) }
    }
  }

  @available(iOS 16.1, *)
  private func endLiveActivity(result: @escaping FlutterResult) {
    let activities = Activity<PrayerActivityAttributes>.activities
    Task {
      for activity in activities {
        await activity.end(dismissalPolicy: .immediate)
      }
      await MainActor.run { result(true) }
    }
  }

  @available(iOS 16.1, *)
  private func decodeContentState(_ arguments: Any?) -> PrayerActivityAttributes.ContentState? {
    guard let dict = arguments as? [String: Any] else { return nil }
    guard
      let activePrayer = dict["activePrayer"] as? String,
      let activePrayerArabic = dict["activePrayerArabic"] as? String,
      let nextPrayer = dict["nextPrayer"] as? String,
      let location = dict["location"] as? String,
      let activeMs = dict["activePrayerEpochMs"] as? NSNumber,
      let nextMs = dict["nextPrayerEpochMs"] as? NSNumber
    else { return nil }

    // Decode the full day schedule (array of {name, epochMs}).
    var schedule: [PrayerActivityAttributes.PrayerStop] = []
    if let rawSchedule = dict["schedule"] as? [[String: Any]] {
      for item in rawSchedule {
        if let name = item["name"] as? String,
           let ms = item["epochMs"] as? NSNumber {
          schedule.append(
            PrayerActivityAttributes.PrayerStop(
              name: name,
              time: Date(timeIntervalSince1970: ms.doubleValue / 1000.0)
            )
          )
        }
      }
    }

    return PrayerActivityAttributes.ContentState(
      activePrayer: activePrayer,
      activePrayerArabic: activePrayerArabic,
      activePrayerTime: Date(timeIntervalSince1970: activeMs.doubleValue / 1000.0),
      nextPrayer: nextPrayer,
      nextPrayerTime: Date(timeIntervalSince1970: nextMs.doubleValue / 1000.0),
      location: location,
      schedule: schedule
    )
  }

  /// The earliest upcoming prayer in the state — used as the activity's
  /// staleDate so iOS re-renders the Live Activity right when a prayer
  /// passes (the view then recomputes "next" from the schedule and the
  /// countdown flips, even while the phone is locked).
  @available(iOS 16.1, *)
  private func nextPrayerDate(
    _ state: PrayerActivityAttributes.ContentState
  ) -> Date {
    let now = Date()
    let future = state.schedule
      .map(\.time)
      .filter { $0 > now }
      .min()
    return future ?? state.nextPrayerTime
  }
}
