//
//  ShimmerDetailView.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 02.12.2024.
//

import SwiftUI


struct ShimmerEventView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {

                ForEach(1..<6) { _ in
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.05)
                            .foregroundStyle(.appLightGray)
                            .frame(
                                height: geometry.size.height * 0.17
                            )
                            .shimmering()
                    }
                }
                
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ShimmerEventView()
}
