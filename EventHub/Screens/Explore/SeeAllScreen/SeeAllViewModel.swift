//
//  SeeAllViewModel.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 13.01.2025.
//

import Foundation
@MainActor 
final class SeeAllViewModel: ObservableObject {
    private let exploreViewModel: ExploreViewModel
    
    let seeAllType: SeeAllExploreType
    
    @Published var todayEvents: [ExploreModel] = []
    @Published var movies: [ExploreModel] = []
    @Published var lists: [ExploreModel] = []
    
    @Published var error: Error? = nil
    
    private var page: Int = 1
    
    init(_ seeAllType: SeeAllExploreType,_ exploreViewModel: ExploreViewModel) {
        self.seeAllType = seeAllType
        self.exploreViewModel = exploreViewModel
    }
    
    func getEvents() -> [ExploreModel] {
        switch seeAllType {
        case .upcomingEvents: return exploreViewModel.upcomingEvents
        case .nearbyYouEvents: return exploreViewModel.nearbyYouEvents
        case .movieEvents: return movies
        case .listEvents: return lists
        case .todayEvents: return todayEvents
        }
    }
    
    
    // MARK: - Task to load data
    func loadData() async {
        switch seeAllType {
        case .todayEvents: await fetchToDayEvents()
        case .movieEvents: await fetchFilms()
        case .listEvents: await fetchLists()
        case .upcomingEvents: await fetchUpcomingEventsIfNeeded()
        case .nearbyYouEvents: await fetchNearbyYouEventsIfNeeded()
        }
    }
    
    // MARK: - Conditional Network Fetch
    private func fetchUpcomingEventsIfNeeded() async {
        if exploreViewModel.upcomingEvents.isEmpty {
            await exploreViewModel.fetchUpcomingEvents()
        }
    }
    
    private func fetchNearbyYouEventsIfNeeded() async {
        if exploreViewModel.nearbyYouEvents.isEmpty {
            await exploreViewModel.featchNearbyYouEvents()
        }
    }
    
    // MARK: - Network API Methods
    private func fetchToDayEvents() async {
        do {
            let fetchedTodayEvents = try await exploreViewModel.apiService.getToDayEvents(
                location: exploreViewModel.currentLocation,
                language: exploreViewModel.language,
                page: page
            )
            
            let objectIDs = fetchedTodayEvents.compactMap { $0.object.id }
            let idString = objectIDs.map(String.init).joined(separator: ",")
            
            let detailsEvents = try await exploreViewModel.apiService.getEventDetails(
                eventIDs: idString,
                language: exploreViewModel.language
            )
            
            self.todayEvents = detailsEvents.map { ExploreModel(dto: $0) }
        } catch {
            self.error = error
        }
    }
    
    private func fetchFilms() async {
        do {
            let fetchedFilms = try await exploreViewModel.apiService.getMovies(
                location: exploreViewModel.currentLocation,
                language: exploreViewModel.language,
                page: page
            )
            print(fetchedFilms)
            self.movies = fetchedFilms.map { ExploreModel(movieDto: $0) }
        } catch {
            self.error = error
        }
    }
    
    private func fetchLists() async {
        do {
            let fetchedList = try await exploreViewModel.apiService.getLists(
                location: exploreViewModel.currentLocation,
                language: exploreViewModel.language,
                page: page
            )
            self.lists = fetchedList.map { ExploreModel(listDto: $0) }
        } catch {
            self.error = error
        }
    }
}


