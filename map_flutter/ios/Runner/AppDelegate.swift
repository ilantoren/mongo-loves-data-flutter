import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let gmsApiKey: String? = ProcessInfo.processInfo.environment["GMS_API_KEY"]
    if ( gmsApiKey != nil) {
        GMSServices.provideAPIKey(gmsApiKey.unsafelyUnwrapped)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
