//
//  DetailView.swift
//  EventHub
//
//  Created by Даниил Сивожелезов on 21.11.2024.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject private var coreDataManager: CoreDataManager
    @StateObject private var viewModel: DetailViewModel
    
    @State private var isPresented: Bool = false
    @State private var isShareViewPresented: Bool = false
    @State private var headerHeight: CGFloat = 320
    @State private var headerMinHeight: CGFloat = 50
   
    @State
    private var headerVisibleRatio: CGFloat = 1

    @State
    private var scrollOffset: CGPoint = .zero
    
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
            VStack {
                if viewModel.event != nil {
                    ScrollViewWithStickyHeader(
                        header: header,
                        headerHeight: headerHeight,
                        headerMinHeight: headerMinHeight,
                        onScroll: handleScrollOffset
                    ) {
                        listItems
                            .padding(.bottom, 40)
                    }
                } else {
                    ShimmerDetailView()
                }
            }
            
            if isPresented {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                ShareView(isPresented: $isPresented)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                    .ignoresSafeArea()
            }
        }
      
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .animation(.easeInOut(duration: 0.3), value: isPresented)
        .task {
            await viewModel.fetchEventDetails()
        }
    }
    
    var listItems: some View {
        VStack(alignment: .leading) {
            headerTitle
            addressAndTime
            
            DetailInformationView(
                bodyText: viewModel.bodyText
            )
        }
        .padding(20)
        
    }
    
    var headerTitle: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(viewModel.title)
                .airbnbCerealFont(.medium, size: 22)
        }
        .opacity(headerVisibleRatio)
    }
    
    var addressAndTime: some View {
        VStack(alignment: .leading) {
            DetailComponentView(
                image: Image(systemName: "calendar"),
                title:  viewModel.startDate,
                description: viewModel.endDate
            )
            
            DetailComponentView(
                image: Image(.location),
                title: viewModel.adress,
                description: viewModel.location
            )
        }
        .opacity(headerVisibleRatio)
    }
    
    func header() -> some View {
        ZStack(alignment: .bottomLeading) {
            ImageDetailView(
                imageUrl: viewModel.image,
                isPresented: $isPresented
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackBarButtonView()
            }
            
            ToolbarItem(placement: .principal) {
                ToolBarTitleView(title: getTitle())
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                ToolBarButton(action:
                    ToolBarAction(
                        icon:
                            isFavorite
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
    
    func handleScrollOffset(_ offset: CGPoint, headerVisibleRatio: CGFloat) {
        self.scrollOffset = offset
        self.headerVisibleRatio = headerVisibleRatio
    }
    
    private func getTitle() -> String {
        if headerVisibleRatio == 1 {
            return Resources.Text.eventDetails.localized
        } else {
            return viewModel.title
        }
    }
    
}

#Preview {
    NavigationView {
        DetailView(detailID: 32532)
            .environmentObject(CoreDataManager())
    }
}
