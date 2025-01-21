//
//  FunctionalButtonsView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 25.11.2024.
//

import SwiftUI

struct FunctionalButtonsView: View {
    let events: [SeeAllExploreType]
    let actions: [SeeAllExploreType: () -> Void]
    @Binding var selectedEvent: SeeAllExploreType?

    var body: some View {
        HStack {
            ForEach(events, id: \.self) { event in
                Button {
                    selectedEvent = event
                    actions[event]?()
                } label: {
                    ZStack {
                        Capsule()
                            .foregroundStyle(.appBlue)
                            .frame(width: 106, height: 39)
                        Text(event.title.uppercased())
                            .airbnbCerealFont(AirbnbCerealFont.medium, size: 15)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

// Пример использования
#Preview {
    var selectedEvent: SeeAllExploreType = .movieEvents

    FunctionalButtonsView(
        events: SeeAllExploreType.buttonCases,
        actions: [
            .todayEvents: { print("Today tapped") },
            .movieEvents: { print("Movies tapped") },
            .listEvents: { print("Lists tapped") }
        ],
        selectedEvent:  .constant(selectedEvent)
    )
}
