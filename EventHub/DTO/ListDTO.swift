//
//  ListItemModel.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 02.12.2024.
//


import Foundation

struct ListDTO: Codable, Identifiable, Sendable {
    let id: Int
    let publicationDate: Date
    let title: String
    let slug: String
    let siteURL: String
}

struct ResponseListDTO: Codable, Sendable {
    let results: [ListDTO]
}
