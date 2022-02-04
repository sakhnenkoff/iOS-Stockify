//
//  PersistenceManager.swift
//  Stockify
//
//  Created by Matthew Sakhnenko on 20.01.2022.
//

import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
    
    private init() {}
    
    //MARK: - Public
    
    var watchList: [String] {
        set {
            if !hasOnboarded {
                userDefaults.set(true, forKey: Constants.onboardedKey)
                setUpDefaults()
            }
            
            userDefaults.set(newValue, forKey: Constants.watchlistKey)
        }
        get {
            let list = userDefaults.value(forKey: Constants.watchlistKey) as? [String]
            return list ?? []
        }
    }
    
    public func addToWatchList(symbol: String, companyName: String) {
        setCompany(company: companyName, symbol: symbol)
        watchList.append(symbol)
        NotificationCenter.default.post(name: .didAddToWatchlist, object: nil)
    }
    
    public func removeFromWatchList(symbol: String) {
        let filteredList = watchList.filter {$0 != symbol}
        watchList = filteredList
    }
    
    //MARK: - Private
    
    private var hasOnboarded: Bool {
        userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    private func setCompany(company: String, symbol: String) {
        userDefaults.set(company, forKey: symbol)
    }
    
    public func setUpDefaults() {
        
        func setNameForKey(dic: [String : String]) {
            dic.keys.map { $0 }
            
            for (symbol,name) in dic {
                userDefaults.set(name, forKey: symbol)
            }
        }
        
        let map = [
            "APPL":"Apple Inc",
            "MSFT":"Microsoft Corporation",
            "SNAP":"Snap Inc",
            "GOOG":"Alphabet",
            "AMZN":"Amazon.com Inc",
            "WORK":"Slack Technologies",
            "FB":"Meta Inc",
            "NVDA":"Nvidia Inc",
            "NKE":"Nike",
            "PINS":"Pinterest Inc",
        ]
        setNameForKey(dic: map)
    
        if let symbols = Array(map.keys.map {$0}) as? [String] {
            self.watchList = symbols
        }
    
    }
    
    public func watchlistContains(symbol: String) -> Bool {
        return watchList.contains(symbol)
    }
    
}
