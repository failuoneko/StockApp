//
//  PersistenceManger.swift
//  StockApp
//
//  Created by L on 2021/11/2.
//

import Foundation

final class PersistenceManger{
    static let shared = PersistenceManger()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        
    }
    
    private init() {}
    
    
    
    // MARK: - Public
    
    public var mainList: [String] {
        return []
    }
    
    public func addToMainList() {
        
    }
    
    public func removeFromMainList() {
        
    }
    
    
    // MARK: - Private
    
    private var hasOnBoarded: Bool {
        return false
    }
    
}
