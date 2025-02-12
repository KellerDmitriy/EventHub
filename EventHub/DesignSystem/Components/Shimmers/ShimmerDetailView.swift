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
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.appLightGray)
                        .frame(height: 80)
                        .shimmering()
                    
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.appLightGray)
                        .frame(width: 250,height: 50)
                        .shimmering()
                    
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.appLightGray)
                        .frame(width: 250,height: 50)
                        .shimmering()
                    
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.appLightGray)
                        .frame(width: 250,height: 80)
                        .shimmering()
                    Spacer()
                }
                .padding(20)
            }
        }
    }
}

#Preview {
    ShimmerDetailView()
}
