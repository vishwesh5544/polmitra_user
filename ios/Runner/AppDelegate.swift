import UIKit
import Flutter
import Google

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Swift
    GMSServices.provideAPIKey("AIzaSyA9uYiQEWW_sGRbdjIH4bT3ykgj4_S-zLE")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
