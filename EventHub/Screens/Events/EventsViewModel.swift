//
//  EventsViewModel.swift
//  EventHub
//
//  Created by Руслан on 18.11.2024.
//

import SwiftUI


// MARK: - EventsViewModel
@MainActor
final class EventsViewModel: ObservableObject {
    // MARK: - Properties
    private let apiService: IAPIServiceForEvents
 
    private let language: Language = .ru
    private let timeIntervalForUpdateCache: TimeInterval = 24 * 60
    
    @Published var selectedMode: EventsMode = .upcoming
    @Published var allEvents: [EventModel] = []
    @Published var upcomingEventsPhase: DataFetchPhase<[EventModel]> = .empty
    @Published var pastEventsPhase: DataFetchPhase<[EventModel]> = .empty
    
    private var page: Int = 1
    
    // MARK: - Initialization
    init(apiService: IAPIServiceForEvents = DIContainer.resolve(forKey: .networkService) ?? EventAPIService()) {
        self.apiService = apiService
    }
    
    func updateAllEvents() async {
        if pastEventsPhase.value == nil {
            await fetchPastEvents()
        }
        
        let upcoming = upcomingEventsPhase.value ?? []
        let past = pastEventsPhase.value ?? []
        
        allEvents = upcoming + past
        allEvents = allEvents.sorted(by: { $0.date < $1.date })
    }
    
    
    // MARK: - Fetch Events
    func fetchUpcomingEvents() async {
        upcomingEventsPhase = .empty
        do {
            let eventsDTO = try await apiService.getUpcomingEvents(
                getActualSince(),
                getActualUntil(),
                language,
                page
            )
            let upcomingEvents = eventsDTO.map { EventModel(dto: $0) }
            upcomingEventsPhase = .success(upcomingEvents)
        } catch {
            upcomingEventsPhase = .failure(error)
        }
    }
    
    func fetchPastEvents() async {
        pastEventsPhase = .empty
        do {
            let eventsDTO = try await apiService.getPastEvents(
                getActualSince(),
                language,
                page
            )
            let pastEvents = eventsDTO.map { EventModel(dto: $0) }
            pastEventsPhase = .success(pastEvents)
        } catch {
            pastEventsPhase = .failure(error)
        }
    }
    
    
    // MARK: - Helpers
    func eventsForCurrentMode() -> [EventModel] {
        switch selectedMode {
        case .upcoming:
            return upcomingEventsPhase.value ?? []
        case .pastEvents:
            return pastEventsPhase.value ?? []
        }
    }
    
    private func getActualSince() -> String {
        let currentDate = Date()
        return String(Int(currentDate.timeIntervalSince1970))
    }
    
    private func getActualUntil() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let untilDate = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return untilDate.iso8601Format()
    }
}

extension EventsViewModel {
    func errorMessage(for phase: DataFetchPhase<[EventModel]>) -> String {
        if case .failure(let error) = phase {
            return error.localizedDescription
        }
        return "Unknown error"
    }
}
