//
//  EventDTO.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 20.11.2024.
//

import Foundation
import CoreLocation

// MARK: - Response
struct APIResponseDTO: Codable, Sendable {
    let results: [EventDTO]
}

// MARK: - Event
struct EventDTO: Codable, Identifiable, Sendable {
    let id: Int
    let title: String
    let images: [ImageDTO]
    let description: String?
    let bodyText: String?
    let favoritesCount: Int?
    let dates: [EventDate]
    let place: PlaceDTO?
    let location: EventLocation?
    let participants: [Participant]?
}


// MARK: - EventCategory
struct CategoryDTO: Codable, Identifiable, Sendable {
    let id: Int
    let slug: String
    let name: String
}

// MARK: - EventCategory
struct EventCategory: Codable, Identifiable, Sendable {
    let id: Int
    let slug: String
    let name: String
}

// MARK: - EventDate
struct EventDate: Codable, Sendable {
    let start: Int?
    let end: Int?
    let startDate: String?
    let startTime: String?
    let endTime: String?
}

// MARK: - Place
struct PlaceDTO: Codable, Sendable {
    let id: Int
    let title: String?
    let slug: String
    let address: String
    let coords: Coordinates
    let location: String
}

// MARK: - Coordinates
struct Coordinates: Codable, Sendable {
    let lat: Double
    let lon: Double
    var toCLLocationCoordinate2D: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
}

// MARK: - Location
struct EventLocation: Codable, Sendable {
    let slug: String
    let name: String?
}

// MARK: - Participant
struct Participant: Codable {
    let role: Role?
    let agent: Agent?
}

// MARK: - Role
struct Role: Codable, Sendable {
    let slug: String?
}

// MARK: - Agent
struct Agent: Codable, Sendable {
    let id: Int
    let title: String?
    let images: [ImageDTO]?
}
// MARK: - Language
enum Language: String, Codable {
    case ru, en
}

// MARK: - EventCategory
struct ImageDTO: Codable, Sendable {
    let image: String?
}
