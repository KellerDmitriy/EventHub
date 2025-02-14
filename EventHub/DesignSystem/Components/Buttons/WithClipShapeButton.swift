//
//  File.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 14.02.2025.
//
import SwiftUI

struct WithClipShapeButton: View {
    let image: ImageResource
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 24, maxHeight: 24)
                .padding(6)
                .background(.white.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.top, 20)
        .padding(.trailing, 16)
    }
}
