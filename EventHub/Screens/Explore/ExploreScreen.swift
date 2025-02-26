
import SwiftUI

struct ExploreScreen: View {
    private enum Drawing {
            static let maxHeight: CGFloat = 255
            static let minHeight: CGFloat = 70
            static let collapseThreshold: CGFloat = -20
            static let opacityThreshold: CGFloat = 200
            static let top: CGFloat = 10
            static let bottom: CGFloat = 180
        }

    //    MARK: - Propreties
    @StateObject var viewModel: ExploreViewModel
    
    @State private var isSearchPresented: Bool = false
    @State private var selectedEventID: Int? = nil
    @State private var selectedSeeAllType: SeeAllExploreType? = nil
    
    @State private var headerHeight: CGFloat = Drawing.maxHeight
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
                .ignoresSafeArea(.all)
            VStack(spacing: 0)  {
                exploreHeader(showMiniStyle: showMiniStyleHeader)
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: headerHeight)
                    .zIndex(1)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0)  {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: proxy.frame(in: .named(ScrollOffsetNamespace.exploreNamespace)).origin
                                )
                        }
                        .frame(height: 0)
                        upcomingEventsSection
                        nearbyEventsSection
                    }
                }
                .coordinateSpace(name: ScrollOffsetNamespace.exploreNamespace)
            }
            
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                withAnimation {
                    showMiniStyleHeader = value.y < Drawing.collapseThreshold
                    headerHeight = showMiniStyleHeader ? Drawing.minHeight : Drawing.maxHeight
                    headerOpacity = max(0, min(1, (Drawing.opacityThreshold + value.y) / Drawing.opacityThreshold))
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
                Spacer()
                cateroryBar
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
                VStack(spacing: 0) {
                    exploreToolBar
                    cateroryBar
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
            selectedEvent: $selectedSeeAllType
        )
        .onChange(of: selectedSeeAllType) { newValue in
            if let type = newValue {
                navigateToSeeAll(type)
            }
        }
    }
    
    private var upcomingEventsSection: some View {
        Group {
            MainCategorySectionView(
                title: Resources.Text.upcomingEventsTitle,
                isShowAll: viewModel.upcomingEvents.isEmpty == false
                )
            .onTapGesture {
                navigateToSeeAll(.upcomingEvents)
            }

            if viewModel.emptyUpcoming {
                NoEventsView()
            } else {
                ScrollEventCardsView(
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
                title: Resources.Text.nearbyEventsTitle,
                isShowAll: viewModel.upcomingEvents.isEmpty == false
                )
            .onTapGesture {
                navigateToSeeAll(.nearbyYouEvents)
            }
            .padding(.top)
            
            if viewModel.emptyNearbyYou {
                NoEventsView()
                    .padding(.bottom, Drawing.bottom)
            } else {
                ScrollEventCardsView(
                    events: viewModel.nearbyYouEvents,
                    showDetail: { event in
                        selectedEventID = event
                    })
                .padding(.bottom, 150)
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
