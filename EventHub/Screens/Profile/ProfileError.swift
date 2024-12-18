//
//  ProfileError.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 18.12.2024.
//


import Foundation

enum ProfileError: LocalizedError {
    
    case logout
    case unknown(Error)
    
    
    var failureReason: String? {
        switch self {
        case .logout:
            return "Log Out"
        case .unknown:
            return "Unknown Error"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .logout:
            return "Are you sure you want to log out?".localized
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    // MARK: - Static Methods
    static func map(_ error: Error) -> ProfileError {
        return error as? ProfileError ?? .unknown(error)
    }
}
