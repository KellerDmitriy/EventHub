//
//  SeeAllEventsView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 30.11.2024.
//

import SwiftUI
// MARK: - SeeAllEventsView
struct SeeAllEventsView: View {
    // MARK: - Properties
    @StateObject var viewModel: SeeAllViewModel
    
    // MARK: - Drawing Constants
    enum Drawing {
        static let cardSpacing: CGFloat = 10
        static let cardPadding: CGFloat = 5
        static let scrollPadding: CGFloat = 10
        static let noImagePlaceholder = "No image"
        static let noImageCrashPlaceholder = "No image/crach"
    }
    
    // MARK: - INIT
    init(_ seeAllType: SeeAllExploreType,_ exploreViewModel: ExploreViewModel)
    {
        self._viewModel = StateObject(wrappedValue: SeeAllViewModel(seeAllType, exploreViewModel)
        )
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Drawing.cardSpacing) {
                ForEach(viewModel.getEvents()) { event in
                   
                    if allowsDetailNavigation {
                        NavigationLink(destination: DetailsScreen(detailID: event.id)) {
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
        .task {
            await viewModel.loadData()
        }
        .alert(isPresented: isPresentedAlert()) {
            Alert(
                title: Text("Alarm"),
                message: Text(viewModel.error?.localizedDescription ?? ""),
                dismissButton: .default(Text("Ok")) {
                    Task {
                        await viewModel.loadData()
                    }
                }
            )
        }
        
        .background(Color.appBackground)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackBarButtonView()
            }
            
            ToolbarItem(placement: .principal) {
                ToolBarTitleView(
                    title: viewModel.seeAllType.title.localized
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Properties

    private func isPresentedAlert() -> Binding<Bool> {
        Binding(
            get: { viewModel.error != nil },
            set: { isPresenting in
                if !isPresenting {
                    viewModel.error = nil
                }
            }
        )
    }
    
    private var allowsDetailNavigation: Bool {
        switch viewModel.seeAllType {
        case .movieEvents, .listEvents: return false
        case .todayEvents, .upcomingEvents, .nearbyYouEvents: return true
        }
    }
    
    // MARK: - Helper Methods
    @ViewBuilder
    func eventView(for event: ExploreModel) -> some View {
        switch viewModel.seeAllType {
        case .upcomingEvents, .nearbyYouEvents, .todayEvents:
            SmallEventCard(
                image: event.image ?? Drawing.noImageCrashPlaceholder,
                date: event.date,
                title: event.title,
                place: event.address ?? "No address"
            )
        case .listEvents:
            ThirdSmallEventCard(
                title: event.title,
                link: event.address ?? "No address"
            )
        case .movieEvents:
            SmallEventCardForMovie(
                image: event.image ?? Drawing.noImagePlaceholder,
                title: event.title,
                url: event.address ?? "No address"
            )
        }
    }
}

// MARK: - Preview
#Preview {
    SeeAllEventsView(SeeAllExploreType.upcomingEvents, ExploreViewModel())
}
