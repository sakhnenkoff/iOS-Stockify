//
//  AppDelegate.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 20.01.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
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
        APICaller.shared.news(for: .company(symbol: "AAPL")) { result in
            switch result {
            case .success(let s):
                print(s)
            case .failure(let e):
                print(e)
            }
        }
    }
}

