
import SwiftUI

struct ExploreScreen: View {
    
    //    MARK: - Propreties
    @StateObject var viewModel: ExploreViewModel
    
    @State private var isSearchPresented: Bool = false
    @State private var selectedEventID: Int? = nil
    @State private var selectedSeeAllType: SeeAllExploreType? = nil
    
    @State private var headerHeight: CGFloat = 210
    @State private var headerVisibleRatio: CGFloat = 1
    @State private var scrollOffset: CGPoint = .zero
    @State private var showMiniStyleHeader: Bool = false
    
    //    MARK: - INIT
    init() {
        self._viewModel = StateObject(wrappedValue: ExploreViewModel()
        )
    }
    
    // MARK: - BODY
    var body: some View {
            VStack(spacing: 0) {
                exploreHeader(showMiniStyle: showMiniStyleHeader)
                    .ignoresSafeArea()
                    .frame(height: headerHeight)
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: proxy.frame(in: .global).height)
                        }
                        .frame(height: 0)
                        upcomingEventsSection
                            
                        nearbyEventsSection
                         
                }
            }
            .padding(.vertical)
            .onPreferenceChange(ScrollOffsetKey .self) { value in
                withAnimation {
                    print(value)
                    showMiniStyleHeader = value < -10
                    headerHeight = max(10, 210 + value)
                }
            }
                
            navigationLinks
        }
        .background(Color.appBackground)
        .task {
            await viewModel.loadAllData()
        }
    }
    
    private func exploreHeader(showMiniStyle: Bool) -> some View {
        VStack(spacing: 0) {
            if showMiniStyle {
                VStack {
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        ToolBarTitleView(title: getTitle())
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
                exploreToolBar
                cateroryBar
                Spacer()
                functionalButtons
                    .padding(.bottom, 12)
            }
        }
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
        .frame(height: 44)
    }
    
    private var upcomingEventsSection: some View {
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
        }
    }
    private var nearbyEventsSection: some View {
        VStack {
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
    
    // MARK: - Navigation Links
    private var navigationLinks: some View {
        Group {
            push(trigger: $selectedEventID) { eventID in
                DetailsScreen(detailID: eventID)
            }
            
            push(trigger: $selectedEventID) { eventID in
                DetailsScreen(detailID: eventID)
            }
            
            push(trigger: $selectedSeeAllType) { seeAllType in
                SeeAllEventsView(seeAllType, viewModel)
            }
        }
    }
//    MARK: - Helpers
    private func getTitle() -> String {
        if headerVisibleRatio < 0.3 {
            return ""
        } else {
            return Resources.Text.explore.localized
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
