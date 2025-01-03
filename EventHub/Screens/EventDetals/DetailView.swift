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
    @State private var headerHeight: CGFloat = 250
    @State private var headerMinHeight: CGFloat = 100
    
    private var isFavorite: Bool {
        coreDataManager.events.contains { event in
            Int(event.id) == viewModel.event?.id
        }
    }
    // MARK: - Init
    init(detailID: Int) {
        self._viewModel = StateObject(wrappedValue: DetailViewModel(eventID: detailID))
    }
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.event != nil {
                    ScrollViewWithCollapsibleHeader(
                        content: {
                            VStack {
                                ImageDetailView(
                                    imageUrl: viewModel.image,
                                    isPresented: $isPresented
                                )
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                DetailInformationView(
                                    title: viewModel.title,
                                    startDate: viewModel.startDate,
                                    endDate: viewModel.endDate,
                                    adress: viewModel.adress,
                                    location: viewModel.location,
                                    agentTitle: viewModel.agentTitle,
                                    role: viewModel.role,
                                    bodyText: viewModel.bodyText
                                )
                            }
                        }
                    )
                } else {
                    ShimmerDetailView()
                        .ignoresSafeArea(.all)
                }
            }
            
            if isPresented {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                ShareView(isPresented: $isPresented)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading ) {
                ToolBarView(
                    title: Resources.Text.eventDetails.localized,
                    foregroundStyle: .white,
                    showBackButton: true,
                    actions: [
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
                    ]
                )
            }
        }
       
        .animation(.easeInOut(duration: 0.3), value: isPresented)
        .task {
            await viewModel.fetchEventDetails()
        }
    }
}

#Preview {
    DetailView(detailID: 32532)
        .environmentObject(CoreDataManager())
}
