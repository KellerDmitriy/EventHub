//
//  ChangeModeButtonsView.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 26.11.2024.
//


import SwiftUI

struct ModeEventsSegmentedControl: View {
    @Binding var state: EventsMode
    @Namespace private var segmentedControl
    
    enum Drawing {
        static let padding: CGFloat = 6
        static let frameHeight: CGFloat = 45
        static let buttonPadding: CGFloat = 8
        static let shadowColor: Color = .gray
        static let shadowOpacity: Double = 0.2
        static let shadowRadius: CGFloat = 10
        static let capsulePadding: CGFloat = 3
    }
    
    var body: some View {
        HStack {
            ForEach(EventsMode.allCases) { mode in
                modeButton(for: mode)
            }
        }
        
        .background(
            Capsule()
                .fill(Color.white)
                .matchedGeometryEffect(
                    id: state,
                    in: segmentedControl,
                    isSource: false
                )
                .shadow(
                    color: Drawing.shadowColor,
                    radius: Drawing.shadowRadius
                )
        )
        .frame(height: Drawing.frameHeight)
        .padding(Drawing.padding)
        .background(Color.fieldGray)
        .clipShape(Capsule())
    }
    
    private func modeButton(for mode: EventsMode) -> some View {
        Button {
            withAnimation {
                self.state = mode
            }
        } label: {
            Text(mode.title)
                .padding(.vertical, Drawing.buttonPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(
                    state == mode ? .appBlue : .appDarkGray
                )
        }
        .matchedGeometryEffect(id: mode, in: segmentedControl)
    }
}

#Preview {
    ModeEventsSegmentedControl(state: .constant(.upcoming))
}
