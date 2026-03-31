import Flutter
import UIKit
import flutter_local_notifications
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let pendingTapPayloadKey = "pending_notification_tap_payload_v1"

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

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
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
}
