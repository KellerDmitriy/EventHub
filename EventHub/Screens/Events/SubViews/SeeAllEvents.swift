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
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            // MARK: - Content Layout
            VStack(spacing: 0) {
                
                // MARK: - Event List
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
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
            }
        }
        
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

        .navigationBarBackButtonHidden()
    }
}

#Preview {
    SeeAllEvents(allEvents: [])
}
