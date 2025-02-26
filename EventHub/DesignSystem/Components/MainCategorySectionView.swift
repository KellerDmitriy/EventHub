//
//  MainCategorySectionView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 20.11.2024.
//

import SwiftUI

struct MainCategorySectionView: View {
    
    let title: String
    var isShowAll = false
    
    var body: some View {
        HStack {
            Text(title.localized)
                .airbnbCerealFont(AirbnbCerealFont.medium, size: 18)
                .frame(width: 200, height: 24, alignment: .leading)
                .foregroundStyle(Color.appForegroundStyle)
                .opacity(0.84)
            
            Spacer()
            if isShowAll {
                Text("See All")
                    .frame(height: 23)
                    .airbnbCerealFont(AirbnbCerealFont.medium, size: 14)
                    .foregroundStyle(.gray)
                    .padding(.trailing, 14)
            }
        }
        .padding(.leading, 24)
    }
}

#Preview {
    MainCategorySectionView(title: "Upcoming Events", isShowAll: true)
}

