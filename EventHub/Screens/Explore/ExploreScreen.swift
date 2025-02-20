//
//  ExploreView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 20.11.2024.
//

import SwiftUI

struct ExploreScreen: View {
    
    @StateObject var viewModel: ExploreViewModel
    
    @State private var isSearchPresented: Bool = false
    @State private var selectedEventID: Int? = nil
    
    @State private var selectedSeeAllType: SeeAllExploreType? = nil
    
    
    
    //    MARK: - INIT
    init() {
        self._viewModel = StateObject(wrappedValue: ExploreViewModel()
        )
    }
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                ExploreToolBar(
                    currentLocation: $viewModel.currentLocation,
                    title: $viewModel.currentPosition,
                    isSearchPresented: $isSearchPresented,
                    isNotifications: true,
                    filterAction:  { orderType in
                        viewModel.filterEvents(orderType: orderType)
                    } ,
                    locations: viewModel.locations)
                
                CategoryScroll(
                    categories:viewModel.categories,
                    onCategorySelected: { selectedCategory in
                        viewModel.currentCategory = selectedCategory.category.slug
                    })
                .offset(y: -23)
                
                ScrollView(showsIndicators: false) {
                    FunctionalButtonsView(
                        events: viewModel.eventTypes,
                        actions: [
                            .todayEvents: { navigateToSeeAll(.todayEvents) },
                            .movieEvents: { navigateToSeeAll(.movieEvents) },
                            .listEvents:  { navigateToSeeAll(.listEvents) }
                        ],
                        selectedEvent: $selectedSeeAllType
                    )
                    .zIndex(1)
                    
                    VStack {
                        MainCategorySectionView(
                            title: "Upcoming Events",
                            action: { navigateToSeeAll(.upcomingEvents) }
                        )
                        .padding(.top, 10)
                        
                        if viewModel.emptyUpcoming {
                            NoEventsView()
                        } else {
                            ScrollEventCardsView(
                                emptyArray: false,
                                events: viewModel.upcomingEvents,
                                showDetail: { event in
                                    selectedEventID = event
                                })
                            .padding(.bottom, 10)
                        }
                        
                        MainCategorySectionView(
                            title: "Nearby You",
                            action: { navigateToSeeAll(.nearbyYouEvents) }
                        )
                        .padding(.bottom, 10)
                        
                        if viewModel.emptyNearbyYou {
                            NoEventsView()
                                .padding(.bottom, 180)
                        } else {
                            ScrollEventCardsView(
                                emptyArray: false,
                                events: viewModel.nearbyYouEvents,
                                showDetail: { event in
                                    selectedEventID = event
                                })
                            .padding(.bottom, 180)
                        }
                    }
                }
                .zIndex(0)
                .navigationBarHidden(true)
            }
            .ignoresSafeArea()
            
            // MARK: - Navigation Links
            push(trigger: $selectedEventID) { eventID in
                DetailsScreen(detailID: eventID)
            }
            
            push(trigger: $selectedSeeAllType) { seeAllType in
                SeeAllEventsView(seeAllType, viewModel)
            }
        }
        .task {
            await viewModel.loadAllData()
        }
    }
    
    // MARK: - Helper Methods
    private func push<T>(trigger: Binding<T?>, @ViewBuilder destination: @escaping (T) -> some View) -> some View {
        NavigationLink(
            destination: trigger.wrappedValue.map { destination($0) },
            isActive: Binding(
                get: { trigger.wrappedValue != nil },
                set: { if !$0 { trigger.wrappedValue = nil } }
            )
        ) {
            EmptyView()
        }
    }
    
    private func navigateToSeeAll(_ type: SeeAllExploreType) {
        selectedSeeAllType = type
    }
}

#Preview {
    ExploreScreen()
        .environmentObject(CoreDataManager())
}
