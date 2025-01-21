//
//  APIClient.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 20.11.2024.
//

import Foundation

protocol APISpec {
    var path: APIPath { get }
    var method: HttpMethod { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
}

// MARK: - API Configuration
struct APIConfig {
    static let scheme = "https"
    static let host = "kudago.com"
    static let basePath = "/public-api/v1.4"
}

// MARK: - API Path Definitions
enum APIPath: String {
    case events
    case movies
    case lists
    case search
    case locations
    case eventCategories = "event-categories"
    
    func fullPath() -> String {
        return APIConfig.basePath + "/" + rawValue
    }
    
    func url(with queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents()
        components.scheme = APIConfig.scheme
        components.host = APIConfig.host
        components.path = fullPath()
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url
    }
}

// MARK: - HTTP Methods
enum HttpMethod: String {
    case get, patch, post, delete
    var desc: String { rawValue.capitalized }
}

// MARK: - API Client
struct APIClient {
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let cache = URLCache(
        memoryCapacity: 10 * 1024 * 1024, // 10 MB
        diskCapacity: 50 * 1024 * 1024,  // 50 MB
        diskPath: "api_cache"
    )
    
    // MARK: - Initializer
    init(session: URLSession = .shared) {
        self.session = session
        URLCache.shared = cache
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - Sending API Request
    func sendRequest<T: Decodable>(
        _ spec: APISpec,
        responseType: T.Type
    ) async throws -> T {
        // Construct the full URL
        guard let url = spec.path.url(with: spec.queryItems) else {
            throw NetworkError.invalidURL
        }
        
        // Prepare the request
        var request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad, // Use cache where possible
            timeoutInterval: 30.0
        )
        request.httpMethod = spec.method.desc
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = spec.body
        
        // Execute the request
        let (data, response) = try await session.data(for: request)
        // Validate the response
//        try validateResponse(response)
        
        // Decode and return the data
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    // MARK: - Response Validation
    private func validateResponse(_ response: URLResponse) throws(NetworkError) {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return // OK
        case 400:
            throw .serverError(statusCode: httpResponse.statusCode, description: "Bad Request")
        case 401:
            throw .serverError(statusCode: httpResponse.statusCode, description: "Unauthorized")
        case 403:
            throw .serverError(statusCode: httpResponse.statusCode, description: "Forbidden")
        case 404:
            throw .serverError(statusCode: httpResponse.statusCode, description: "Not Found")
        case 500:
            throw .serverError(statusCode: httpResponse.statusCode, description: "Internal Server Error")
        default:
            throw .serverError(statusCode: httpResponse.statusCode, description: "Unhandled Error")
        }
    }
}


// MARK: - URLRequest Extension for Debugging
extension URLRequest {
    var debugDescription: String {
        var description = "[\(httpMethod ?? "UNKNOWN")] \(url?.absoluteString ?? "N/A")\n"
        
        if let headers = allHTTPHeaderFields {
            description += "Headers: \(headers)\n"
        }
        
        if let body = httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            description += "Body: \(bodyString)"
        }
        
        return description
    }
}
