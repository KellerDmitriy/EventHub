//
//  DetailsScreen.swift
//  EventHub
//
//  Created by Даниил Сивожелезов on 21.11.2024.
//

import SwiftUI

struct DetailsScreen: View {
    @EnvironmentObject private var coreDataManager: CoreDataManager
    @StateObject private var viewModel: DetailViewModel
    
    @State private var isSharePresented: Bool = false

    @State private var headerHeight: CGFloat = 320
    
    @State private var headerVisibleRatio: CGFloat = 1
    
    @State private var scrollOffset: CGPoint = .zero
    
    private var isFavorite: Bool {
        coreDataManager.events.contains { event in
            Int(event.id) == viewModel.event?.id
        }
    }
    
    // MARK: - Drawing Constants
    private struct Drawing {
        static let titleFontSize: CGFloat = 24
        static let spacingBetweenButtons: CGFloat = 16
    }
    
    // MARK: - Init
    init(detailID: Int) {
        self._viewModel = StateObject(wrappedValue: DetailViewModel(eventID: detailID))
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            if viewModel.event != nil {
                ScrollViewWithStickyHeader(
                    header: header,
                    headerHeight: headerHeight,
                    onScroll: handleScrollOffset
                ) {
                    listItems
                        .padding(.bottom, 40)
                }
            } else {
                ShimmerDetailView()
            }
            
            if isSharePresented {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                ShareView(isPresented: $isSharePresented)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                    .ignoresSafeArea()
            }
        }
        .navigationBarBackButtonHidden()
        .animation(.easeInOut(duration: 0.3), value: isSharePresented)
        .task {
            await viewModel.fetchEventDetails()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackBarButtonView()
            }
            
            ToolbarItem(placement: .principal) {
                ToolBarTitleView(title: getTitle())
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                ToolBarButton(
                    action:
                        ToolBarAction(
                            icon: isFavorite
                            ? ToolBarButtonType.bookmarkFill.icon
                            : ToolBarButtonType.bookmark.icon,
                            action: {
                                if !isFavorite {
                                    if let event = viewModel.event {
                                        coreDataManager.createEvent(event: event)
                                    }
                                } else {
                                    coreDataManager.deleteEvent(eventID: viewModel.eventID)
                                }
                            },
                            hasBackground: true,
                            foregroundStyle: .white
                        )
                )
            }
        }
    }
    
    var listItems: some View {
        DetailInformationView(
            title: viewModel.title,
            startDate: viewModel.startDate,
            endDate: viewModel.endDate,
            adress: viewModel.adress,
            location: viewModel.location,
            bodyText: viewModel.bodyText
        )
        .padding(20)
    }
    
    func header() -> some View {
        ImageDetailView(
            headerVisibleRatio: headerVisibleRatio,
            imageUrl: viewModel.image
        )
        .overlay(alignment: .topTrailing) {
            WithClipShapeButton(image: .share) {
                isSharePresented.toggle()
            }
            .padding(.top, 90)
        }
    }
    
    func handleScrollOffset(_ offset: CGPoint, headerVisibleRatio: CGFloat) {
        self.scrollOffset = offset
        self.headerVisibleRatio = headerVisibleRatio
    }
    
    private func getTitle() -> String {
        if headerVisibleRatio < 0.3 {
            return viewModel.title
        } else {
            return Resources.Text.eventDetails.localized
        }
    }
}

#Preview {
    NavigationView {
        DetailsScreen(detailID: 32532)
            .environmentObject(CoreDataManager())
    }
}
