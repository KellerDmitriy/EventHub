//
//  EventsScreen.swift
//  EventHub
//
//  Created by Руслан on 18.11.2024.
//
import SwiftUI

struct EventsScreen: View {
    @StateObject var viewModel: EventsViewModel
    @State private var showAllEvents = false

    // MARK: - Drawing Constants
    private enum Drawing {
        // Padding and Sizes
        static let horizontalPadding: CGFloat = 24
        static let buttonHorizontalPadding: CGFloat = 53
        static let buttonBottomPadding: CGFloat = 40
        
        // Texts
        static let errorText: String = "Error occurred. Pull to refresh."
        static let exploreEventsText: String = "Explore Events".localized
        static let toolbarTitle: String = "Event".localized
        static let alertTitle: String = "Error"
        static let alertOkButton: String = "OK"
    }

    // MARK: - INIT
    init() {
        self._viewModel = StateObject(wrappedValue: EventsViewModel())
    }

    // MARK: - BODY
    var body: some View {
            VStack {
                ModeEventsSegmentedControl(state: $viewModel.selectedMode)
                    .padding(Drawing.horizontalPadding)
                    .onChange(of: viewModel.selectedMode) { newValue in
                        Task {
                            await loadEvents(for: newValue)
                        }
                    }

                Group {
                    switch currentPhase(for: viewModel.selectedMode) {
                    case .empty:
                        ShimmerEventView()
                            .padding(.horizontal, Drawing.horizontalPadding)
                    case .success(let events):
                        if events.isEmpty {
                            EmptyEventsView(selectedMode: viewModel.selectedMode)
                        } else {
                            ScrollView(.vertical) {
                                VStack {
                                    ForEach(events) { event in
                                        NavigationLink(destination: DetailView(detailID: event.id)) {
                                            SmallEventCard(
                                                image: event.image,
                                                date: event.date,
                                                title: event.title,
                                                place: event.location
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, Drawing.horizontalPadding)
                            }
                        }
                    case .failure:
                        Text(Drawing.errorText)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                BlueButtonWithArrow(text: Drawing.exploreEventsText) {
                    Task {
                        await viewModel.updateAllEvents()
                    }
                    showAllEvents = true
                }
                .padding(.horizontal, Drawing.buttonHorizontalPadding)
                .padding(.bottom, Drawing.buttonBottomPadding)
                .background(
                    NavigationLink(
                        destination: SeeAllEvents(allEvents: viewModel.allEvents),
                        isActive: $showAllEvents,
                        label: { EmptyView() }
                    )
                )
            }
            .background(Color.appBackground)
        
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ToolBarTitleView(title: Drawing.toolbarTitle)
                     
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchUpcomingEvents()
            }
            .alert(isPresented: isPresentedAlert(for: $viewModel.upcomingEventsPhase)) {
                Alert(
                    title: Text(Drawing.alertTitle),
                    message: Text(viewModel.errorMessage(for: viewModel.upcomingEventsPhase)),
                    dismissButton: .default(Text(Drawing.alertOkButton)) {
                        Task {
                            await loadEvents(for: viewModel.selectedMode)
                        }
                    }
                )
            }
        }
    

    // MARK: - Helper Methods
    private func currentPhase(for mode: EventsMode) -> DataFetchPhase<[EventModel]> {
        switch mode {
        case .upcoming:
            return viewModel.upcomingEventsPhase
        case .pastEvents:
            return viewModel.pastEventsPhase
        }
    }

    private func isPresentedAlert(for phase: Binding<DataFetchPhase<[EventModel]>>) -> Binding<Bool> {
        Binding(
            get: {
                if case .failure = phase.wrappedValue {
                    return true
                }
                return false
            },
            set: { isPresented in
                if !isPresented {
                    phase.wrappedValue = .empty
                }
            }
        )
    }

    private func loadEvents(for mode: EventsMode) async {
        switch mode {
        case .upcoming:
            await viewModel.fetchUpcomingEvents()
        case .pastEvents:
            await viewModel.fetchPastEvents()
        }
    }
}

#Preview {
    EventsScreen()
}
