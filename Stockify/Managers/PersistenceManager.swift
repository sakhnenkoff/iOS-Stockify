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
        
    }
    
    private init() {}
    
    //MARK: - Public
    
    var watchList = [String]()
    
    public func addToWatchList() {
        
    }
    
    public func removeFromWatchList() {
        
    }
    
    //MARK: - Private
    
    private var hasOnboarded = false
    
    
}
