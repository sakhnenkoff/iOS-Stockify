//
//  NotificationManager.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 30.01.2022.
//

import UIKit
import UserNotifications
import FirebaseMessaging

protocol NotificationManagerDelegate: AnyObject {
    func didInitializeNotification(status: Bool, message: String?)
}

final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private override init() {}
    
    public weak var delegate: NotificationManagerDelegate?
    
    private var currentNotificationSetting: UNNotificationSettings?
    
    var fbtoken: String? = nil
    
    public func configureFB() {
        configureFCM()
    }
    
    public func initializeNotificationServices() {
                
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.delegate = self
        
        center.requestAuthorization(options: options) { (granted, error) in

            guard granted else {
                let message = "Authorization denied"
                self.delegate?.didInitializeNotification(status: false, message: message)
                return
            }
            
            self.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
        
        notificationAuthorization { settings in
            guard settings.authorizationStatus == .authorized else {
                let message = "Authorization denied"
                self.delegate?.didInitializeNotification(status: false, message: message)
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                self.delegate?.didInitializeNotification(status: true, message: nil)
            }
        }
    }
    
    @objc private func notificationAuthorization(completion: ((UNNotificationSettings) -> Void)? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            if let current = self.currentNotificationSetting {
                if current != settings {
                    
                    self.currentNotificationSetting = settings
                    
                    completion?(settings)
                    return
                }
            }
            
            self.currentNotificationSetting = settings
            completion?(settings)
        }
    }
    
    private func configureFCM() {
        Messaging.messaging().delegate = self
    }
}

// MARK: UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler
        completionHandler: @escaping () -> Void) {
    }
}

// MARK: MessagingDelegate

extension NotificationManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            guard let token = token else { return }
            print("Token: \(token)")
            self.fbtoken = token
        }
    }
}
