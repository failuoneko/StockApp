//
//  PersistenceManger.swift
//  StockApp
//
//  Created by L on 2021/11/2.
//

import Foundation

final class PersistenceManager {
    
    // MARK: - Properties
    
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
    
    private init() {}
    
    // MARK: - Public
    
    public var watchlist: [String] {
        if !hasOnBoarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            congureDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    
    /// 判斷此股票是否已有加進watchlist。
    public func watchlistContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }
    
    /// Add list
    public func addToWatchlist(symbol: String, companyName: String) {
        var current = watchlist
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchlistKey)
        userDefaults.set(companyName, forKey: symbol)

        NotificationCenter.default.post(name: .didAddToWatchlist, object: nil)
    }
    
    /// Remove list
    public func removeFromWatchlist(symbol: String) {
        var newList: [String] = []
        
//        print("DEBUG: deleting: [\(symbol)]")

        // 移除key
        userDefaults.set(nil, forKey: symbol)
        
        // watchlist裡面沒有該公司簡稱，就追加到list裡，然後覆蓋掉舊的key。
        for item in watchlist where item != symbol {
//            print("DEBUG: item: [\(item)]")
            newList.append(item)
        }

        userDefaults.set(newList, forKey: Constants.watchlistKey)
    }
    
    
    // MARK: - Private
    
    private var hasOnBoarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    // 預設watchlist
    private func congureDefaults() {
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com, Inc.",
            "FB": "Facebook Inc.",
            "NVDA": "Nvidia Inc.",
            "NKE": "Nike",
            "PINS": "Pinterest Inc."
        ]
        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)
        
        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
    
}
