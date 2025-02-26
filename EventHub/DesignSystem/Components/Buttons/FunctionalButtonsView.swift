//
//  FunctionalButtonsView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 25.11.2024.
//

import SwiftUI

struct FunctionalButtonsView: View {
    let events: [SeeAllExploreType]

    @Binding var selectedEvent: SeeAllExploreType?

    var body: some View {
        HStack {
            ForEach(events, id: \.self) { event in
                Button {
                    selectedEvent = event
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


#Preview {
    FunctionalButtonsView(
        events: SeeAllExploreType.buttonCases,
        selectedEvent: .constant(.upcomingEvents)
    )
}
