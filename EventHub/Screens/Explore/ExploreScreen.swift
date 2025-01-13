//
//  ExploreView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 20.11.2024.
//

import SwiftUI

struct ExploreScreen: View {
    enum CategoryType {
        case today, films, lists
    }
    
    @StateObject var viewModel: ExploreViewModel
    
    @State private var isSearchPresented: Bool = false
    @State private var selectedEventID: Int? = nil
    @State private var isDetailPresented: Bool = false
    @State private var isSeeAllUpcomingEvents: Bool = false
    
    @State private var isTodayEvents: Bool = false
    @State private var isFilms: Bool = false
    @State private var isLists: Bool = false
    
    @State private var isSeeAllNearbyEvents: Bool = false
    
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
                    
                    FunctionalButtonsView(
                        names: viewModel.functionalButtonsNames,
                        actions: [
                            { Task { await loadData(for: .today)}},
                            { Task { await loadData(for: .films)}},
                            { Task { await loadData(for: .lists)}}
                        ],
                        chooseButton: $viewModel.choosedButton
                    )
                .zIndex(1)
                ScrollView(showsIndicators: false) {
                    VStack {
                        MainCategorySectionView(
                            isPresented: $isSeeAllUpcomingEvents,
                            title: "Upcoming Events",
                            linkActive: !viewModel.emptyUpcoming
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
                                    isDetailPresented = true
                                })
                            .padding(.bottom, 10)
                        }
                        
                        MainCategorySectionView(
                            isPresented: $isSeeAllNearbyEvents,
                            title: "Nearby You",
                            linkActive: !viewModel.emptyNearbyYou
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
                                    isDetailPresented = true
                                })
                            .padding(.bottom, 180)
                        }
                    }
                }
                .zIndex(0)
                .navigationBarHidden(true)
            }
            .ignoresSafeArea()
        }

        .navigationLink(
            destination: SeeAllEventsView(events: viewModel.upcomingEvents, eventType: .upcomingEvents),
            isActive: $isSeeAllUpcomingEvents
        )
        .navigationLink(
            destination: SeeAllEventsView(events: viewModel.nearbyYouEvents, eventType: .nearbyYouEvents),
            isActive: $isSeeAllNearbyEvents
        )
        .navigationLink(
            destination: SearchView(searchScreenType: .withoutData),
            isActive: $isSearchPresented
        )
        
        .navigationLink(
            destination: DetailView(detailID: selectedEventID ?? 0),
            isActive: $isDetailPresented
        )
        
        .navigationLink(
            destination: SeeAllEventsView(events: viewModel.todayEvents, eventType: .today),
            isActive: $isTodayEvents
        )
        
        .navigationLink(
            destination: SeeAllEventsView(events: viewModel.films, eventType: .movie),
            isActive: $isFilms
        )
        
        .navigationLink(
            destination: SeeAllEventsView(events: viewModel.lists, eventType: .lists),
            isActive: $isLists
        )
        .task {
            await viewModel.loadAllData()
        }
    }
    
    
    
    // MARK: - Task to load data
    private func loadData(for type: CategoryType) async {
        switch type {
        case .today:
            await viewModel.getToDayEvents()
            isTodayEvents = true
        case .films:
            await viewModel.getFilms()
            isFilms = true
        case .lists:
            await viewModel.getLists()
            isLists = true
        }
    }
    
}

#Preview {
    ExploreScreen()
}
