//
//  UDStorageService.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 29.11.2024.
//

import Foundation

protocol IStorageService {
    var isRememberMeOn: Bool { get set }
    var hasCompleteOnboarding: Bool { get set }
}

final class UDStorageService: IStorageService {
    private let bd = UserDefaults.standard
    
    enum Key: String {
        case hasCompletedOnboarding
        case isRememberMeOn
    }
    
    func set(value: Bool, forKey key: Key) {
        bd.set(value, forKey: key.rawValue)
    }
    
    func getValue(forKey key: Key) -> Bool {
        bd.bool(forKey: key.rawValue)
    }
    
    var isRememberMeOn: Bool {
        get { getValue(forKey: .isRememberMeOn) }
        set { set(value: newValue, forKey: .isRememberMeOn) }
    }
    
    var hasCompleteOnboarding: Bool {
        get { getValue(forKey: .hasCompletedOnboarding) }
        set { set(value: newValue, forKey: .hasCompletedOnboarding) }
    }
}
