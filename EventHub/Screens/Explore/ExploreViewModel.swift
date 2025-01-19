//
//  ExploreViewViewModel.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 20.11.2024.
//

import SwiftUI

@MainActor
final class ExploreViewModel: ObservableObject {
    
    let apiService: IAPIServiceForExplore
    
    let eventTypes = SeeAllExploreType.buttonCases
    @Published var emptyUpcoming = false
    @Published var emptyNearbyYou = false
    
    @Published var currentPosition: String = "Moscow".localized
    
    @Published var upcomingEvents: [ExploreModel] = []
    @Published var nearbyYouEvents: [ExploreModel] = []
    
    @Published var categories: [CategoryUIModel] = []
    @Published var locations: [EventLocation] = []
    
    @Published var error: Error? = nil
    
    @Published var currentLocation: String = "msk" {
        didSet{
            Task {
                await featchNearbyYouEvents()
            }
        }
    }
    
    @Published var currentCategory: String? = nil {
        didSet{
            Task {
                await fetchUpcomingEvents()
                await featchNearbyYouEvents()
            }
        }
    }
    
    @Published var isLoadingNextPage = false
    @Published var hasMoreUpcomingEvents = true
    @Published var hasMoreNearbyYouEvents = true
    
    let language = Language.ru
    
    private var page: Int = 1
    
    // MARK: - INIT
    init(apiService: IAPIServiceForExplore = DIContainer.resolve(forKey: .networkService) ?? EventAPIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Filter Events
    func filterEvents(orderType: DisplayOrderType) {
        switch orderType {
        case .alphabetical:
            upcomingEvents = upcomingEvents.sorted(by: { $0.title < $1.title })
            nearbyYouEvents = nearbyYouEvents.sorted(by: { $0.title < $1.title })
        case .date:
            upcomingEvents = upcomingEvents.sorted(by: { $0.date < $1.date })
            nearbyYouEvents = nearbyYouEvents.sorted(by: { $0.date < $1.date })
        }
    }
    
    
    // MARK: - Network API Methods
    func loadAllData() async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    await self.fetchCategories()
                }
                group.addTask {
                    await self.fetchLocations()
                }
                try await group.waitForAll()
            }
            
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    await self.fetchUpcomingEvents()
                }
                group.addTask {
                    await self.featchNearbyYouEvents()
                }
            }
        } catch {
            self.error = error
        }
    }
    
    func fetchLocations() async {
        do {
            let fetchedLocations = try await apiService.getLocations(with: language)
            self.locations = fetchedLocations
            
        } catch {
            self.error = error
        }
    }
    
    func fetchCategories() async {
        do {
            let categoriesFromAPI = try await apiService.getCategories(with: language)
            await loadCategories(from: categoriesFromAPI)
        } catch {
            self.error = error
        }
    }
    
    func fetchUpcomingEvents() async {
        do {
            let fetchedEvents = try await apiService.getUpcomingEvents(
                with: currentCategory,
                language,
                page
            )
            
            let mappedEvents = fetchedEvents.map { ExploreModel(dto: $0) }
            
            let filteredEvents = ExploreModel.filterExploreEvents(mappedEvents)
            
            self.upcomingEvents = filteredEvents
            
        } catch {
            self.error = error
        }
    }
    
    func featchNearbyYouEvents() async {
        do {
            let eventsDTO = try await apiService.getNearbyYouEvents(
                with: language,
                currentLocation,
                currentCategory,
                page
            )
            let mappedEvents = eventsDTO.map { ExploreModel(dto: $0) }
            let filteredEvents = ExploreModel.filterExploreEvents(mappedEvents)
            nearbyYouEvents = filteredEvents
            
        } catch {
            self.error = error
        }
    }
    
    
    //    MARK: - Helper Methods
    private func loadCategories(from eventCategories: [CategoryDTO]) async {
        let mappedCategories = eventCategories.map { category in
            let color = CategoryImageMapping.color(for: category)
            let image = CategoryImageMapping.image(for: category)
            return CategoryUIModel(id: category.id, category: category, color: color, image: image)
        }
        self.categories = mappedCategories
    }
    
    
    // MARK: - Pagination for Upcoming Events
    func loadNextPageForUpcomingEvents() async {
        guard !isLoadingNextPage && hasMoreUpcomingEvents else { return }
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }
        
        do {
            page += 1
            let fetchedEvents = try await apiService.getUpcomingEvents(
                with: currentCategory,
                language,
                page
            )
            if fetchedEvents.isEmpty {
                hasMoreUpcomingEvents = false
            } else {
                let mappedEvents = fetchedEvents.map { ExploreModel(dto: $0) }
                upcomingEvents.append(contentsOf: ExploreModel.filterExploreEvents(mappedEvents))
            }
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Pagination for Nearby You Events
    func loadNextPageForNearbyYouEvents() async {
        guard !isLoadingNextPage && hasMoreNearbyYouEvents else { return }
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }
        
        do {
            page += 1
            let fetchedEvents = try await apiService.getNearbyYouEvents(
                with: language,
                currentLocation,
                currentCategory,
                page
            )
            if fetchedEvents.isEmpty {
                hasMoreNearbyYouEvents = false
            } else {
                let mappedEvents = fetchedEvents.map { ExploreModel(dto: $0) }
                nearbyYouEvents.append(contentsOf: ExploreModel.filterExploreEvents(mappedEvents))
            }
        } catch {
            self.error = error
        }
    }
}
