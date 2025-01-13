//
//  NetworkError.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 20.11.2024.
//

import Foundation

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, description: String)
    case dataConversionFailure
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server response is invalid."
        case .serverError(let statusCode, let description):
            return "Server error (\(statusCode)): \(description)"
        case .dataConversionFailure:
            return "Failed to decode the server response."
        }
    }
}
