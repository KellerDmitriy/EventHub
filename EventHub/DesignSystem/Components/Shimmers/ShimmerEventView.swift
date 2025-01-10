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
                Spacer()
                ForEach(1..<4) { _ in
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.05)
                            .foregroundStyle(.appLightGray)
                            .frame(
                                width: geometry.size.width * 0.9,
                                height: geometry.size.height * 0.1
                            )
                            .shimmering()
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview
#Preview {
    ShimmerEventView()
}
