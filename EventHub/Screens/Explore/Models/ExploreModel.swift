//
//  ExploreModel.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 20.11.2024.
//

import Foundation

protocol EventConvertible {
    var id: Int { get }
    var title: String { get }
    var eventDate: Date { get }
    var address: String? { get }
    var image: String? { get }
}

struct ExploreModel: Identifiable {
    let id: Int
    let title: String
    let visitors: [Visitor]?
    let date: Date
    let address: String?
    let image: String?
    
    static let example = ExploreModel(
        id: 123,
        title: "International Band Music Concert",
        visitors: [Visitor(image: "visitor", name: "Sonya"),
                   Visitor(image: "visitor", name: "Sonya"),
                   Visitor(image: "visitor", name: "Sonya"),
                   Visitor(image: "visitor", name: "Sonya")],
        date: .now,
        address: "36 Guild Street London, UK",
        image: "cardImg1")
}

extension ExploreModel: EventConvertible {
    var eventDate: Date { self.date }
}

extension ExploreModel {
    init(dto: EventDTO) {
        self.id = dto.id
        self.title = dto.title.capitalized
        self.visitors = dto.participants?.map { participant in
            Visitor(
                image: participant.agent?.images?.first?.image,
                name: participant.agent?.title
            )
        }
        
        let currentDate = Date()
        let closestDate = dto.dates
            .filter { $0.start != nil }
            .map { Date(timeIntervalSince1970: TimeInterval($0.start!)) }
            .filter { $0 > currentDate }
            .min(by: { abs($0.timeIntervalSince(currentDate)) < abs($1.timeIntervalSince(currentDate)) })
        
        self.date = closestDate ?? Date(timeIntervalSince1970: 1489312800)
        let location = dto.location?.name
        let place = dto.place?.address
        self.address = "\(String(describing: place)), \(String(describing: location))"
        self.image = dto.images.first?.image
    }
}


extension ExploreModel {
    init(movieDto: MovieDTO) {
        self.id = movieDto.id
        self.title = movieDto.title
        self.visitors = []
        self.date = (Date(timeIntervalSince1970: TimeInterval(movieDto.year)))
        self.address = movieDto.site_url
        self.image = movieDto.poster.image
    }
}
    
extension ExploreModel {
    init(listDto: ListDTO) {
        self.id = listDto.id
        self.title = listDto.title
        self.visitors = []
        self.date = listDto.publicationDate
        self.address = listDto.siteURL
        self.image = listDto.siteURL
    }
}

extension ExploreModel {
    init(searchDTO: SearchResultDTO) {
        self.id = searchDTO.id
        self.title = searchDTO.title
        self.visitors = []
        self.date = (Date(timeIntervalSince1970: TimeInterval(searchDTO.daterange?.start ?? 1489312800)))
        self.address = searchDTO.place?.address
        self.image = searchDTO.firstImage?.image
    }
}

extension ExploreModel {
    init(model: MapEventModel) {
        self.id = model.id
        self.title = model.title
        self.visitors = []
        self.date = model.date
        self.address = model.place
        self.image = model.image
    }
}

extension ExploreModel {
    init(event: EventModel) {
        self.id = event.id
        self.title = event.title
        self.visitors = []
        self.date = event.date
        self.address = event.location
        self.image = event.image
    }
}

extension ExploreModel {
    init(event: FavoriteEvent) {
        self.id = event.id
        self.title = event.title ?? ""
        self.visitors = []
        self.date = event.date ?? Date()
        self.address = event.adress
        self.image = event.image
    }
}

struct EventIdentifier: Hashable {
    let id: Int
    let title: String
}

extension ExploreModel {
    static func filterExploreEvents(_ events: [ExploreModel]) -> [ExploreModel] {
        let currentDate = Date()
        var seenIdsAndTitles: Set<EventIdentifier> = []
        
        let groupedEvents = Dictionary(grouping: events) { EventIdentifier(id: $0.id, title: $0.title) }
        
        let filteredEvents = groupedEvents.values.compactMap { group -> ExploreModel? in
            group.filter { $0.date >= currentDate }
                 .min(by: { abs($0.date.timeIntervalSince(currentDate)) < abs($1.date.timeIntervalSince(currentDate)) })
        }
        
        return filteredEvents.filter { event in
            let eventPair = EventIdentifier(id: event.id, title: event.title)
            if seenIdsAndTitles.contains(eventPair) {
                return false
            } else {
                seenIdsAndTitles.insert(eventPair)
                return true
            }
        }
    }
}

struct Visitor {
    let image: String?
    let name: String?
}
