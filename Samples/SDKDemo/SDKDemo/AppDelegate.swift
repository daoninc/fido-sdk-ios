//
//  AppDelegate.swift
//
//  Copyright © 2019-22 Daon. All rights reserved.
//

import UIKit
import UserNotifications
import DaonFIDOSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    print("Notification permission granted: \(granted)")
                    
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        print("Notification settings: \(settings)")
                        
                        guard settings.authorizationStatus == .authorized else { return }
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
            }
        }
        
        if let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            handleRemoteNotification(notification, launch: true)
        }
        
        return true
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        IXUAF.setPushNotificationService(token: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications:", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        handleRemoteNotification(userInfo, launch: false)
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }

    func handleRemoteNotification(_ notification: [AnyHashable: Any], launch: Bool) {
        Settings.shared.set(key: Settings.Key.notification, value: notification)
        
        if !launch {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Notification"), object: nil)
        }
    }

}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard scene is UIWindowScene else { return }

        if let response = connectionOptions.notificationResponse {
            (UIApplication.shared.delegate as? AppDelegate)?
                .handleRemoteNotification(response.notification.request.content.userInfo, launch: true)
        }
    }
}
