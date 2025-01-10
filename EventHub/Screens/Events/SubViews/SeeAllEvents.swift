//
//  SeeAllEvents.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 25.11.2024.
//

import SwiftUI

struct SeeAllEvents: View {
    
    // MARK: - Properties
    @State private var showSearchFlow = false
    let allEvents: [EventModel]
    
    // MARK: - Body
    var body: some View {
        // MARK: - Event List
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(allEvents) { event in
                    NavigationLink(destination: DetailView(detailID: event.id)) {
                        SmallEventCard(
                            image: event.image,
                            date: event.date,
                            title: event.title,
                            place: event.location
                        )
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(10)
        }
        .overlay(
            NavigationLink(
                destination: SearchView(
                    searchScreenType: .withData,
                    localData: allEvents.map { ExploreModel(event: $0) }
                ),
                isActive: $showSearchFlow,
                label: { EmptyView() }
            )
        )
        .background(Color.appBackground)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackBarButtonView()
            }
            ToolbarItem(placement: .principal) {
                ToolBarTitleView(title: Resources.Text.event.localized)
               
            }
            ToolbarItem(placement: .topBarTrailing)  {
                ToolBarButton(action: ToolBarAction(
                    icon: ToolBarButtonType.search.icon,
                    action: { showSearchFlow = true },
                    hasBackground: false,
                    foregroundStyle: Color.appBlue
                )
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    SeeAllEvents(allEvents: [])
}
