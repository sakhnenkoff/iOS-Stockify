//
//  AppDelegate.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 20.01.2022.
//

import UIKit
import UserNotifications
import FirebaseMessaging
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        NotificationManager.shared.initializeNotificationServices()
        NotificationManager.shared.configureFB()
        
        debug()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
      
    }

    private func debug() {
      
    }
    
//    private func configureFirebaseNotifications() {
//        FirebaseApp.configure()
//
//        Messaging.messaging().delegate = self
//        UNUserNotificationCenter.current().delegate = self
//
//        requestForNotificationAuth()
//    }
//
//    private func requestForNotificationAuth() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { status, error in
//            guard status else { return }
//            print("Success in APNS registry")
//
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
//    }
}

//extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        messaging.token { token, error in
//            guard let token = token else { return }
//
//            print("Token: \(token)")
//        }
//    }
//}

