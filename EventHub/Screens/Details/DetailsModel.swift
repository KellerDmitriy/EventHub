//
//  ExploreModel.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 02.12.2024.
//

import Foundation

struct DetailsModel: Identifiable {
    let id: Int
    let title: String
    let startDate: Date
    let endDate: Date
    let participants: [Participant]?
    let description: String?
    let bodyText: String?
    let address: String?
    let location: String?
    let image: String?
}

extension DetailsModel: EventConvertible {
    var eventDate: Date { self.startDate }
}

extension DetailsModel {
    init(dto: EventDTO) {
        self.id = dto.id
        self.title = dto.title
       
        let currentDate = Date()
        let closestDate = dto.dates
            .filter { $0.start != nil }
            .map { Date(timeIntervalSince1970: TimeInterval($0.start!)) }
            .filter { $0 > currentDate }
            .min(by: { abs($0.timeIntervalSince(currentDate)) < abs($1.timeIntervalSince(currentDate)) })
        self.startDate = closestDate ?? currentDate
   
        let endTimestamp = dto.dates.last?.end
        self.endDate = Date(timeIntervalSince1970: TimeInterval(endTimestamp ?? 1489312800))
        self.description = dto.description
        self.bodyText = dto.bodyText
        self.participants = dto.participants
        self.address = dto.place?.title
        self.location = dto.place?.address
        self.image = dto.images.first?.image
    }
}
