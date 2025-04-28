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
}

extension NetworkError {
    init?(_ statusCode: Int) {
        switch statusCode {
        case 400:
            self = .serverError(statusCode: statusCode, description: "Bad Request")
        case 401:
            self = .serverError(statusCode: statusCode, description: "Unauthorized")
        case 403:
            self = .serverError(statusCode: statusCode, description: "Forbidden")
        case 404:
            self = .serverError(statusCode: statusCode, description: "Not Found")
        case 500:
            self = .serverError(statusCode: statusCode, description: "Internal Server Error")
        default:
            return nil
        }
    }
}
