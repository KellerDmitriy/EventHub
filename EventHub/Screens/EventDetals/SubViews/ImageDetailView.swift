//
//  ImageDetailView.swift
//  EventHub
//
//  Created by Даниил Сивожелезов on 30.11.2024.
//

import SwiftUI
import Kingfisher

struct ImageDetailView: View {
    var headerVisibleRatio: CGFloat
    
    let imageUrl: String?
    
    var body: some View {
        ZStack {
            ScrollViewHeaderGradient(.appPurpleSecondary, .appBackground)
            ScrollViewHeaderGradient(
                .appPurpleSecondary.opacity(1),
                .appPurpleSecondary.opacity(0)
            )
                .opacity(1 - headerVisibleRatio)
            cover
        }

    }
    
    var cover: some View {
        KFImage(url)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .clipped()
            .cornerRadius(5)
            .shadow(radius: 10)
            .rotation3DEffect(
                .degrees(rotationDegrees), axis: (x: 1, y: 0, z: 0)
            )
            .offset(y: verticalOffset)
            .opacity(headerVisibleRatio)
            .padding(.top, 65)
            .padding(.bottom, 20)
            .padding(.horizontal, 16)
        
    }
    
    
    
    var url: URL? {
        guard let imageUrl, let url = URL(string: imageUrl) else { return nil }
        return url
    }
    
    var rotationDegrees: CGFloat {
        guard headerVisibleRatio > 1 else { return 0 }
        let value = 20.0 * (1 - headerVisibleRatio)
        return value.capped(to: -5...0)
    }
    
    var verticalOffset: CGFloat {
        guard headerVisibleRatio < 1 else { return 0 }
        return 70.0 * (1 - headerVisibleRatio)
    }
}

private extension CGFloat {
    func capped(to range: ClosedRange<Self>) -> Self {
        if self < range.lowerBound { return range.lowerBound }
        if self > range.upperBound { return range.upperBound }
        return self
    }
}

#Preview {
    ImageDetailView(headerVisibleRatio: .zero, imageUrl: "https://media.kudago.com/images/movie/poster/02/9f/029fde701e0100acb6268194f7a25749.jpg"
                    )
        .frame(height: 320)
}
