//
//  ToolBarTitleView.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 18.11.2024.
//


import SwiftUI

struct ToolBarTitleView: View {
    let title: String
    let foregroundStyle: Color = .appForegroundStyle
    
    // MARK: - Drawing Constants
    private struct Drawing {
        static let titleFontSize: CGFloat = 24
        static let maxToolbarWidth: CGFloat = UIScreen.main.bounds.width * 0.6
        static let maxToolbarHeight: CGFloat = 44 
    }
    
    var body: some View {
        Text(title)
            .airbnbCerealFont(AirbnbCerealFont.medium, size: Drawing.titleFontSize)
            .foregroundStyle(foregroundStyle)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: Drawing.maxToolbarWidth, maxHeight: Drawing.maxToolbarHeight)
    }
}
