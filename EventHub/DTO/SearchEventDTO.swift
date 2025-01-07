//
//  SearchEventDTO.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 01.12.2024.
//


import Foundation

// MARK: - Welcome
struct SearchResponseDTO: Codable, Sendable {
    let results: [SearchResultDTO]
}

// MARK: - Result
struct SearchResultDTO: Codable, Identifiable, Sendable {
    let id: Int
    let slug, title: String
    let description: String
    let itemURL: String?
    let place: Place?
    let daterange: Daterange?
    let firstImage: FirstImage?
}

// MARK: - Daterange
struct Daterange: Codable, Sendable {
    let start: Int?
    let end: Int?
    let startDate: Int?
    let startTime: Int?
    let endTime: Int?
}

// MARK: - FirstImage
struct FirstImage: Codable, Sendable {
    let image: String
}


// MARK: - Place
struct Place: Codable, Identifiable, Sendable {
    let id: Int
    let title, slug, address: String
    let coords: Coords
    let location: String
}

// MARK: - Coords
struct Coords: Codable, Sendable {
    let lat, lon: Double
}
