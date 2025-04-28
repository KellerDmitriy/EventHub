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
    func addRecentSearch(text: String)
    func getRecentSearch() -> [String]
    func removeRecentSearch(text: String)
}

final class UDStorageService: IStorageService {

    // MARK: - Private Properties
    private let bd = UserDefaults.standard
    private let maxSearchHistoryCount = 10
    
    // MARK: - Keys
    private enum Key: String {
        case hasCompletedOnboarding
        case isRememberMeOn
        case searchHistory
    }
    
    // MARK: - Private Methods
    private func set(value: Bool, forKey key: Key) {
        bd.set(value, forKey: key.rawValue)
    }
    
    private func getValue(forKey key: Key) -> Bool {
        bd.bool(forKey: key.rawValue)
    }
    
    // MARK: - Public Properties
    var isRememberMeOn: Bool {
        get { getValue(forKey: .isRememberMeOn) }
        set { set(value: newValue, forKey: .isRememberMeOn) }
    }
    
    var hasCompleteOnboarding: Bool {
        get { getValue(forKey: .hasCompletedOnboarding) }
        set { set(value: newValue, forKey: .hasCompletedOnboarding) }
    }
    
    // MARK: - Recent Searches
    func addRecentSearch(text: String) {
        var searchHistory = getRecentSearch()
        
        searchHistory.removeAll { $0 == text }
        searchHistory.insert(text, at: 0)
        
        if searchHistory.count > maxSearchHistoryCount {
            searchHistory = Array(searchHistory.prefix(maxSearchHistoryCount))
        }
        
        bd.setValue(searchHistory, forKey: Key.searchHistory.rawValue)
    }
    
    func getRecentSearch() -> [String] {
        bd.stringArray(forKey: Key.searchHistory.rawValue) ?? []
    }
    
    func removeRecentSearch(text: String) {
        var searchHistory = getRecentSearch()
        searchHistory.removeAll { $0 == text }
        bd.setValue(searchHistory, forKey: Key.searchHistory.rawValue)
    }
}
