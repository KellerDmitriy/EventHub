//
//  TextOnlyButton.swift
//  EventHub
//
//  Created by Денис Гиндулин on 24.11.2024.
//

import SwiftUI

struct TextOnlyButton: View {
    let title: String
    let color: Color = .appBlue
    let font: AirbnbCerealFont = .medium
    let opacity: Double = 1.0
    let titleFontSize: CGFloat = 14
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .foregroundStyle(color.opacity(opacity))
                .airbnbCerealFont(font, size: CGFloat(titleFontSize))
        }
    }
}

