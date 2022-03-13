import UIKit
import Flutter
import GoogleMaps
import Braintree


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyDjgUxgzitqoYObIabR-kHs17NiBPObKMc")
    GeneratedPluginRegistrant.register(with: self)
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    BTAppContextSwitcher.setReturnURLScheme("com.template.bookAppointment.payments")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
