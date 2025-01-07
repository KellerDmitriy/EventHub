//
//  Poster.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 02.12.2024.
//


import Foundation

struct MoviesResponseDTO: Codable, Sendable {
    let results: [MovieDTO]
}

struct MovieDTO: Codable, Identifiable, Sendable {
    let id: Int
    let site_url: String
    let title: String
    let year: Int
    let poster: Poster
}

struct Poster: Codable, Sendable {
    let image: String
}



