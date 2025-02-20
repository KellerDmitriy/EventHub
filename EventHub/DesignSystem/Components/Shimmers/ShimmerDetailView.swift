//
//  ShimmerDetailView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 29.11.2024.
//

import SwiftUI

struct ShimmerDetailView: View {
    var body: some View {
        ZStack {
            Color.fieldGray
                .ignoresSafeArea()
            VStack {
                Rectangle()
                    .frame(height: 400)
                    .foregroundStyle(.appLightGray)
                    .shimmering()
                
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.appLightGray)
                        .frame(height: 80)
                        .shimmering()
                    
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.appLightGray)
                        .frame(width: 250,height: 50)
                        .shimmering()
                    
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.appLightGray)
                        .frame(width: 250,height: 50)
                        .shimmering()
                    
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.appLightGray)
                        .frame(width: 250,height: 80)
                        .shimmering()
                }
                .padding(.top, 12)
                .padding(.horizontal)
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ShimmerDetailView()
}
