import Flutter
import UIKit
import UserNotifications
import flutter_local_notifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Taps and actions on notifications reach flutter_local_notifications,
    // and reminders are shown while the app is in the foreground too.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

    // Periodic refresh of reminders (see lib/app/background_tasks.dart). The
    // identifier must match BGTaskSchedulerPermittedIdentifiers in Info.plist.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "com.app.yoo.refresh",
      earliestBeginInSeconds: NSNumber(value: 60 * 60)
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Plugins available in the isolate that handles notification actions
    // while the app is in background (lib/app/bootstrap.dart).
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
