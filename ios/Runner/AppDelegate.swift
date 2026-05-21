import Flutter
import UIKit
import flutter_local_notifications
import UserNotifications
import ActivityKit
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let pendingTapPayloadKey = "pending_notification_tap_payload_v1"
  private static let liveActivityChannelName = "com.osmyildiz.digitalminaret/live_activity"
  private static let liveActivityRefreshIdentifier =
    "com.osmyildiz.digitalminaret.liveactivity_refresh"
  // BGProcessingTask companion to the BGAppRefreshTask above. iOS treats
  // these as separate task pools and may run one even when it skips the
  // other; registering both maximises the chance of getting at least one
  // background refresh overnight, when most users have the phone idle
  // and on a charger (matches BGProcessingTask's preferred conditions).
  private static let liveActivityOvernightIdentifier =
    "com.osmyildiz.digitalminaret.liveactivity_overnight"
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

    // BGTaskScheduler.register MUST be called synchronously before
    // didFinishLaunchingWithOptions returns, otherwise the system never
    // delivers the scheduled task. The actual scheduling happens on
    // backgrounding.
    if #available(iOS 16.1, *) {
      BGTaskScheduler.shared.register(
        forTaskWithIdentifier: Self.liveActivityRefreshIdentifier,
        using: nil
      ) { task in
        self.handleLiveActivityRefresh(task: task as! BGAppRefreshTask)
      }
      BGTaskScheduler.shared.register(
        forTaskWithIdentifier: Self.liveActivityOvernightIdentifier,
        using: nil
      ) { task in
        self.handleLiveActivityOvernight(task: task as! BGProcessingTask)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    if #available(iOS 16.1, *) {
      scheduleLiveActivityRefresh()
      scheduleLiveActivityOvernight()
    }
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

  /// Activities still updateable by the app. iOS keeps system-ended /
  /// user-dismissed activities in `Activity.activities` for hours after
  /// they stop being visible; without filtering, the start/update path
  /// would call `update(...)` on a dead activity (silent no-op) and
  /// never recreate a visible one — that's what made the Live Activity
  /// "disappear" overnight until the user toggled the setting off/on.
  @available(iOS 16.1, *)
  private func liveActivities() -> [Activity<PrayerActivityAttributes>] {
    Activity<PrayerActivityAttributes>.activities.filter {
      $0.activityState != .ended && $0.activityState != .dismissed
    }
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

    // If a live (non-ended/dismissed) activity already exists, update
    // instead of creating a duplicate. Filtering by activityState here
    // is what lets the app recreate the activity after iOS auto-ends it
    // (e.g. the 8h-no-update staleness limit) without the user having
    // to toggle the setting off and on.
    if let existing = liveActivities().first {
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
    let activities = liveActivities()
    guard !activities.isEmpty else {
      // No updateable activity → tell Flutter to fall through to start.
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

  // MARK: - Background refresh

  /// Asks iOS for a future background slot to re-push the Live Activity
  /// so its view recomputes from a fresh `Date()`. Without this, the
  /// timeline marker and active-prayer banner freeze at the last render
  /// time while the phone is locked overnight (the big H:MM:SS
  /// countdown keeps ticking on its own — only the schedule-derived
  /// view elements freeze). iOS decides when to actually run the task
  /// based on user habits, battery, and system load; we treat it as
  /// best-effort and rely on the next app open as the fallback.
  @available(iOS 16.1, *)
  private func scheduleLiveActivityRefresh() {
    // No point asking iOS for a refresh slot if no activity is live.
    guard !liveActivities().isEmpty else { return }
    let request = BGAppRefreshTaskRequest(
      identifier: Self.liveActivityRefreshIdentifier
    )
    // Earliest in 30 minutes — iOS treats this as a floor and may
    // delay further. Chaining (we re-submit after each run) approximates
    // periodic refresh through the night.
    request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      // Background App Refresh disabled by user, duplicate submission,
      // or unsupported device. Nothing to do — the activity will refresh
      // on next foreground.
    }
  }

  @available(iOS 16.1, *)
  private func handleLiveActivityRefresh(task: BGAppRefreshTask) {
    // Reschedule before doing work — iOS allows only one in-flight task
    // per identifier, so resubmitting here keeps the chain going.
    scheduleLiveActivityRefresh()

    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }

    let activities = liveActivities()
    if activities.isEmpty {
      task.setTaskCompleted(success: true)
      return
    }

    Task {
      for activity in activities {
        let currentState: PrayerActivityAttributes.ContentState
        if #available(iOS 16.2, *) {
          currentState = activity.content.state
        } else {
          currentState = activity.contentState
        }
        // Re-pushing the same content forces iOS to re-render the view
        // body; scheduleActive / scheduleNext / DayTimelineView all call
        // Date() at render time, so the marker, active-prayer banner,
        // and "next prayer" line all advance to the correct values for
        // the current wall clock without needing a server push.
        let stale = nextPrayerDate(currentState)
        if #available(iOS 16.2, *) {
          await activity.update(
            ActivityContent(state: currentState, staleDate: stale)
          )
        } else {
          await activity.update(using: currentState)
        }
      }
      await MainActor.run {
        task.setTaskCompleted(success: true)
      }
    }
  }

  /// Companion to scheduleLiveActivityRefresh. BGProcessingTask gives us
  /// a longer execution window (~1 minute) and is preferentially fired by
  /// iOS when the phone is idle and on a charger — the exact conditions
  /// that produced the overnight freeze before this fix, since most
  /// prayer-app users sleep with the phone charging. Both task types are
  /// chained: whichever iOS happens to fire keeps the Live Activity
  /// fresh, and the next submission queues another window.
  @available(iOS 16.1, *)
  private func scheduleLiveActivityOvernight() {
    guard !liveActivities().isEmpty else { return }
    let request = BGProcessingTaskRequest(
      identifier: Self.liveActivityOvernightIdentifier
    )
    // Earliest in 2 hours — a BGProcessingTask is meant for less frequent,
    // longer work than BGAppRefreshTask. We mostly want one good run
    // during the overnight Isha→Fajr stretch, not constant polling.
    request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60 * 60)
    // Don't gate on the charger — many users sleep without plugging in.
    // iOS still strongly prefers to run BGProcessingTask while charging
    // when possible, so leaving this false gets the best of both worlds.
    request.requiresExternalPower = false
    request.requiresNetworkConnectivity = false
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      // Same fall-through as scheduleLiveActivityRefresh: BAR disabled,
      // duplicate submission, or unsupported. The other task type may
      // still fire, and the next foreground re-pushes anyway.
    }
  }

  @available(iOS 16.1, *)
  private func handleLiveActivityOvernight(task: BGProcessingTask) {
    // Same chaining and refresh logic as the BGAppRefreshTask handler.
    scheduleLiveActivityOvernight()

    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }

    let activities = liveActivities()
    if activities.isEmpty {
      task.setTaskCompleted(success: true)
      return
    }

    Task {
      for activity in activities {
        let currentState: PrayerActivityAttributes.ContentState
        if #available(iOS 16.2, *) {
          currentState = activity.content.state
        } else {
          currentState = activity.contentState
        }
        let stale = nextPrayerDate(currentState)
        if #available(iOS 16.2, *) {
          await activity.update(
            ActivityContent(state: currentState, staleDate: stale)
          )
        } else {
          await activity.update(using: currentState)
        }
      }
      await MainActor.run {
        task.setTaskCompleted(success: true)
      }
    }
  }
}
