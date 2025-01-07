//
//  ToDayEventDTO.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 02.12.2024.
//


struct ToDayEventsDTO: Codable, Sendable {
    let results: [ToDayEventDTO]
}

// MARK: - ToDayEventDTO
struct ToDayEventDTO: Codable, Sendable {
    let date, location: String
    let object: Object
    let title: String
}

// MARK: - Object
struct Object: Codable, Sendable {
    let id: Int
    let ctype: String
}
