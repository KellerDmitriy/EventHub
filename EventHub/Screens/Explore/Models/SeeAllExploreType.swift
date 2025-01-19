//
//  EventType.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 14.01.2025.
//


// MARK: - EventType
enum SeeAllExploreType: Hashable, CaseIterable {
    case upcomingEvents
    case nearbyYouEvents
    case todayEvents
    case movieEvents
    case listEvents
    
    var title: String {
        switch self {
        case .upcomingEvents: return "Upcoming Events"
        case .nearbyYouEvents: return "Nearby You"
        case .todayEvents: return "Today"
        case .movieEvents: return "Movies"
        case .listEvents: return "Lists"
        }
    }
}

// MARK: - Protocol for Categorization
protocol HeaderType {}
protocol ButtonType {}

// MARK: - Extensions to Categorize Cases
extension SeeAllExploreType: HeaderType {
    static var headerCases: [SeeAllExploreType] {
        return [.upcomingEvents, .nearbyYouEvents]
    }
}

extension SeeAllExploreType: ButtonType {
    static var buttonCases: [SeeAllExploreType] {
        return [.todayEvents, .movieEvents, .listEvents]
    }
}
