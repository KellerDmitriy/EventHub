//
//  EventsScreen.swift
//  EventHub
//
//  Created by Руслан on 18.11.2024.
//
import SwiftUI

struct EventsScreen: View {
    @StateObject var viewModel: EventsViewModel
    @State private var showAllEvents: Bool? = nil
    @State private var selectedEventID: Int? = nil
    
    // MARK: - Drawing Constants
    private enum Drawing {
        // Padding and Sizes
        static let horizontalPadding: CGFloat = 24
        static let topPadding: CGFloat = 12
        
        // Texts
        static let errorText: String = "Error occurred. Pull to refresh."
        static let exploreEventsText: String = "Explore all Events".localized
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
        ZStack(alignment: .bottom) {
            VStack {
                ModeEventsSegmentedControl(state: $viewModel.selectedMode)
                    .padding(.top, Drawing.topPadding)
                    .padding(.horizontal, Drawing.horizontalPadding)
                    .onChange(of: viewModel.selectedMode) { newValue in
                        Task {
                            await loadEvents(for: newValue)
                        }
                    }
                HStack {
                    Spacer()
                    TextOnlyButton(title: Drawing.exploreEventsText) {
                        Task {
                            await viewModel.updateAllEvents()
                        }
                        showAllEvents = true
                    }
                    .padding(.trailing, Drawing.horizontalPadding)
                    .padding(.top, Drawing.topPadding)
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
                                        SmallEventCard(
                                            image: event.image,
                                            date: event.date,
                                            title: event.title,
                                            place: event.location
                                        )
                                        .onTapGesture {
                                            self.selectedEventID = event.id
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
                // MARK: - Navigation Links
                push(trigger: $selectedEventID) { eventID in
                    DetailsScreen(detailID: eventID)
                }
                
                push(trigger: $showAllEvents) { eventID in
                    SeeAllEvents(viewModel: viewModel)
                }
            }
            .background(Color.appBackground)

        }
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
