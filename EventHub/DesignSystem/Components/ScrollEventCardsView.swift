//
//  ScrollEventCardsView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 20.11.2024.
//

import SwiftUI

struct ScrollEventCardsView: View {

    let emptyArray: Bool
    let events: [ExploreModel]
    var showDetail: (Int) -> Void
    
    
    var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if events.isEmpty  {
                        ForEach(1..<6) { plug in
                            ShimmerView(ratio: 1)
                        }
                    } else {
                        ForEach(events) { event in
                            EventCardView(event: event, showDetail: showDetail)
                                .padding(.vertical, 10)
                        }
                    }
                }
                .padding(.leading, 24)
            }
    }
}

#Preview {
    ScrollEventCardsView(emptyArray: true, events: [ExploreModel.example, ExploreModel.example], showDetail: {_ in } )
}
