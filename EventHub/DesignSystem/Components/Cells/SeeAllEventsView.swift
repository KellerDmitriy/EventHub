//
//  SeeAllEventsView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 30.11.2024.
//

import SwiftUI

// MARK: - EventType
enum EventType {
    case upcomingEvents
    case nearbyYouEvents
    case movie
    case lists
    case today
    
    var title: String {
        switch self {
        case .upcomingEvents:
            return "Upcoming Events"
        case .nearbyYouEvents:
            return "Nearby You"
        case .movie:
            return "Movies"
        case .lists:
            return "Lists"
        case .today:
            return "Today"
        }
    }
}



// MARK: - SeeAllEventsView
struct SeeAllEventsView: View {
    
    // MARK: - Properties
    let events: [ExploreModel]
    let eventType: EventType
    
    // MARK: - Drawing Constants
    enum Drawing {
        static let cardSpacing: CGFloat = 10
        static let cardPadding: CGFloat = 5
        static let scrollPadding: CGFloat = 20
        static let noImagePlaceholder = "No image"
        static let noImageCrashPlaceholder = "No image/crach"
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Drawing.cardSpacing) {
                ForEach(events) { event in
                    if allowsDetailNavigation {
                        NavigationLink(destination: DetailView(detailID: event.id)) {
                            eventView(for: event)
                                .padding(.bottom, Drawing.cardPadding)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        eventView(for: event)
                            .padding(.bottom, Drawing.cardPadding)
                    }
                }
            }
            .padding(Drawing.scrollPadding)
        }
        .background(Color.appBackground)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ToolBarView(
                    title: eventType.title.localized,
                    showBackButton: true
                )
            }
        }
    }
    
    // MARK: - Helper Properties
    private var allowsDetailNavigation: Bool {
        switch eventType {
        case .movie, .lists, .today:
            return false
        default:
            return true
        }
    }
    
    // MARK: - Helper Methods
    @ViewBuilder
    func eventView(for event: ExploreModel) -> some View {
        switch eventType {
        case .lists:
            ThirdSmallEventCard(
                title: event.title,
                link: event.adress
            )
        case .movie:
            SmallEventCardForMovie(
                image: event.image ?? Drawing.noImagePlaceholder,
                title: event.title,
                url: event.adress
            )
        case .today, .upcomingEvents, .nearbyYouEvents:
            SmallEventCard(
                image: event.image ?? Drawing.noImageCrashPlaceholder,
                date: event.date,
                title: event.title,
                place: event.adress
            )
        }
    }
}

// MARK: - Preview
#Preview {
    SeeAllEventsView(events: [], eventType: .nearbyYouEvents)
}
