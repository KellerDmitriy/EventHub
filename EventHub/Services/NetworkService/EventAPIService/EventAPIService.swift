//
//  EventAPIService.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 20.11.2024.
//

import Foundation

/// `EventAPIService` interacts with the KudaGo API to retrieve event data.
/// Includes fetching locations, categories, events, event details, and search results.
final class EventAPIService: IEventAPIService {
    
    let apiClient: APIClient

    // MARK: - Initializer
    /// Initializes the EventAPIService with an API client.
    init() {
        self.apiClient = APIClient()

    }
    
    // MARK: - Locations
    /// Fetches a list of available locations.
    func getLocations(with language: Language?) async throws -> [EventLocation] {
        let apiSpec: EventAPISpec = .getLocation(language: language)
        return try await apiClient.sendRequest(apiSpec, responseType: [EventLocation].self)
    }
    
    // MARK: - Categories
    /// Fetches event categories based on the provided language.
    /// 
    func getCategories(with language: Language?) async throws -> [CategoryDTO] {
        let apiSpec: EventAPISpec = .getCategories(language: language)
        return try await apiClient.sendRequest(apiSpec, responseType: [CategoryDTO].self)
    }
    
    // MARK: - Events
    func getToDayEvents(location: String, language: Language?, page: Int?) async throws -> [ToDayEventDTO] {
        let apiSpec: EventAPISpec = .getTodayEvents(location: location, language: language, page: page)
        let response = try await apiClient.sendRequest(apiSpec, responseType: ToDayEventsDTO.self)
        return response.results
    }
    
    func getMovies(location: String, language: Language?, page: Int?) async throws -> [MovieDTO] {
        let apiSpec: EventAPISpec = .getMovies(location: location, language: language, page: page)
        let response = try await apiClient.sendRequest(apiSpec, responseType: MoviesResponseDTO.self)
        return response.results
    }
    
    func getLists(location: String, language: Language?, page: Int?) async throws -> [ListDTO] {
        let apiSpec: EventAPISpec = .getLists(location: location, language: language, page: page)
        return try await apiClient.sendRequest(apiSpec, responseType: [ListDTO].self)
    }
    

    /// Fetches a paginated list of events filtered by location, language, and category.
    func getUpcomingEvents(with category: String?, _ language: Language, _ page: Int?) async throws -> [EventDTO] {
        let apiSpec: EventAPISpec = .getUpcomingEventsWith(
            category: category,
            language: language,
            page: page
        )
        let response: APIResponseDTO = try await apiClient.sendRequest(apiSpec, responseType: APIResponseDTO.self)
        return response.results
    }
    
    func getNearbyYouEvents(with language: Language?, _ location: String, _ category: String?, _ page: Int?) async throws -> [EventDTO] {
        let apiSpec: EventAPISpec = .getNearbyYouEvents(language: language, location: location, category: category, page: page)

        let response: APIResponseDTO = try await apiClient.sendRequest(apiSpec, responseType: APIResponseDTO.self)
        return response.results
    }
    
    // MARK: - Event Details
    /// Fetches detailed information about a specific event.
    func getEventDetails(eventIDs: String, language: Language?) async throws -> [EventDTO] {
        let apiSpec = EventAPISpec.getEventDetails(eventIDs: eventIDs, language: language)
        let response: APIResponseDTO = try await apiClient.sendRequest(apiSpec, responseType: APIResponseDTO.self)
        return response.results
    }
    
    func getUpcomingEvents(_ actualSince: String, _ actualUntil: String, _ language: Language, _ page: Int?) async throws -> [EventDTO] {
        let apiSpec: EventAPISpec = .getUpcominglEvents(
            actualSince: actualSince,
            actualUntil: actualUntil,
            language: language,
            page: page
        )
        let response: APIResponseDTO = try await apiClient.sendRequest(apiSpec, responseType: APIResponseDTO.self)
        return response.results
    }
    
    func getPastEvents(_ actualUntil: String, _ language: Language, _ page: Int?) async throws -> [EventDTO] {
        let apiSpec: EventAPISpec = .getPastEvents(actualUntil: actualUntil, language: language, page: page)
        let response: APIResponseDTO = try await apiClient.sendRequest(apiSpec, responseType: APIResponseDTO.self)
        return response.results
    }
    
    // MARK: - Search
    /// Searches for events using a text query.
    func getSearchedEvents(with searchText: String) async throws -> SearchResponseDTO? {
        let apiSpec: EventAPISpec = .getSerchedEventsWith(searchText: searchText)
        return try await apiClient.sendRequest(apiSpec, responseType: SearchResponseDTO.self)
    }
    
    func getEventsWith(location: String, _ category: String?,_ language: Language) async throws -> [EventDTO] {
        let apiSpec: EventAPISpec = .getEventsForMap(coordinate: location, category: category, language: language)
        return try await apiClient.sendRequest(apiSpec, responseType: APIResponseDTO.self).results
    }
}
