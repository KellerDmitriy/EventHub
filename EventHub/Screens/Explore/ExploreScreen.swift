
import SwiftUI

struct ExploreScreen: View {
    
    //    MARK: - Propreties
    @StateObject var viewModel: ExploreViewModel
    
    @State private var isSearchPresented: Bool = false
    @State private var selectedEventID: Int? = nil
    @State private var selectedSeeAllType: SeeAllExploreType? = nil
    
    @State private var headerHeight: CGFloat = 265
    @State private var headerOpacity: Double = 1.0
    @State private var showMiniStyleHeader: Bool = false
    
    //    MARK: - INIT
    init() {
        self._viewModel = StateObject(wrappedValue: ExploreViewModel()
        )
    }
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack {
                exploreHeader(showMiniStyle: showMiniStyleHeader)
                    .frame(height: headerHeight)
                    .zIndex(1)
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetKey.self,
                                    value: proxy.frame(in: .named("scroll")).minY
                                )
                        }
                        .frame(height: 0)
                        upcomingEventsSection
                        nearbyEventsSection
                    }
                }
                .coordinateSpace(name: "scroll")
            }
            
            .ignoresSafeArea()
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                let newShowMiniStyle = value < -20
                let newHeaderHeight: CGFloat = newShowMiniStyle ? 150 : 265
                let newOpacity = max(0, min(1, (200 + value) / 200))
                
                guard newShowMiniStyle != showMiniStyleHeader || newHeaderHeight != headerHeight || newOpacity != headerOpacity else { return }
                
                withAnimation {
                    showMiniStyleHeader = newShowMiniStyle
                    headerHeight = newHeaderHeight
                    headerOpacity = newOpacity
                }
            }
            
            navigationLinks
        }
        .task {
            await viewModel.loadAllData()
        }
    }
    
    private func exploreHeader(showMiniStyle: Bool) -> some View {
        VStack(spacing: 0) {
            if showMiniStyle {
                VStack {
                        cateroryBar
                }
                    .padding(.top, 150)
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        ToolBarTitleView(title: viewModel.currentPosition)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        ToolBarButton(action: ToolBarAction(
                            icon: ToolBarButtonType.search.icon,
                            action: { isSearchPresented = true },
                            hasBackground: false,
                            foregroundStyle: Color.appBlue)
                        )
                    }
                }
                
            } else {
                VStack {
                    exploreToolBar
                    cateroryBar
                    Spacer()
                    functionalButtons
                       
                }
                .opacity(headerOpacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showMiniStyle)
    }
    
    //    MARK: - Components
    private var exploreToolBar: some View {
        ExploreToolBar(
            currentLocation: $viewModel.currentLocation,
            title: $viewModel.currentPosition,
            isSearchPresented: $isSearchPresented,
            isNotifications: true,
            filterAction:  { orderType in
                viewModel.filterEvents(orderType: orderType)
            } ,
            locations: viewModel.locations
        )
    }
    
    private var cateroryBar: some View {
        CategoryScroll(
            categories: viewModel.categories,
            onCategorySelected: { selectedCategory in
                viewModel.currentCategory = selectedCategory.category.slug
            })
        .offset(y: -23)
    }
    
    private var functionalButtons: some View {
        FunctionalButtonsView(
            events: viewModel.eventTypes,
            actions: [
                .todayEvents: { navigateToSeeAll(.todayEvents) },
                .movieEvents: { navigateToSeeAll(.movieEvents) },
                .listEvents:  { navigateToSeeAll(.listEvents) }
            ],
            selectedEvent: $selectedSeeAllType
        )
    }
    
    private var upcomingEventsSection: some View {
        Group {
            MainCategorySectionView(
                title: "Upcoming Events",
                action: { navigateToSeeAll(.upcomingEvents) }
            )
            .padding(.top)
            
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
        }
    }
    private var nearbyEventsSection: some View {
        Group {
            MainCategorySectionView(
                title: "Nearby You",
                action: { navigateToSeeAll(.nearbyYouEvents) }
            )
            .padding(.top)
            
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
    
    // MARK: - Navigation Links
    private var navigationLinks: some View {
        Group {
            NavigationLink(
                destination: SearchView(searchScreenType: .withoutData),
                isActive: $isSearchPresented
            ) {
                EmptyView()
            }
            
            push(trigger: $selectedEventID) { eventID in
                DetailsScreen(detailID: eventID)
            }
            
            push(trigger: $selectedSeeAllType) { seeAllType in
                SeeAllEventsView(seeAllType, viewModel)
            }
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
    NavigationView {
        ExploreScreen()
            .environmentObject(CoreDataManager())
    }
}
