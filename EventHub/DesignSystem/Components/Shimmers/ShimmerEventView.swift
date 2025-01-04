//
//  ShimmerDetailView.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 02.12.2024.
//

import SwiftUI

struct ShimmerEventView: View {
    var body: some View {
        VStack {
            Spacer()
            ForEach (1..<5) { _ in
                VStack(alignment: .leading, spacing: 20) {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.appLightGray)
                        .frame(height: 100)
                        .shimmering()
                    
                }
            }
            Spacer()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ShimmerEventView()
}
