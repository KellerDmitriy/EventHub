//
//  ScrollViewHeaderGradient.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 12.02.2025.
//


import SwiftUI

/// This view can be used as a header view overlay, when the
/// background may cause the content to be hard to overview.
///
/// This is basically just a convenience, to avoid having to
/// use a `LinearGradient` from scratch.
public struct ScrollViewHeaderGradient: View {

    /// Create a scroll view header gradient.
    ///
    /// - Parameters:
    ///   - startColor: The top start color, by default `.clear`.
    ///   - endColor: The bottom end color, by default semi-black.
    public init(
        _ startColor: Color = .clear,
        _ endColor: Color? = nil
    ) {
        self.init(startColor, .top, endColor, .bottom)
    }

    /// Create a scroll view header gradient.
    ///
    /// - Parameters:
    ///   - startColor: The top start color, by default `.clear`.
    ///   - startPoint: The top start point.
    ///   - endColor: The bottom end color, by default semi-black.
    ///   - endPoint: The top start point.
    public init(
        _ startColor: Color = .clear,
        _ startPoint: UnitPoint,
        _ endColor: Color? = nil,
        _ endPoint: UnitPoint
    ) {
        self.startColor = startColor
        self.startPoint = startPoint
        self.endColor = endColor ?? .black.opacity(0.4)
        self.endPoint = endPoint
    }

    private let startColor: Color
    private let startPoint: UnitPoint
    private let endColor: Color
    private let endPoint: UnitPoint

    public var body: some View {
        LinearGradient(
            colors: [startColor, endColor],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

#Preview {

    VStack {
        ScrollViewHeaderGradient()
        ScrollViewHeaderGradient(.blue, .topLeading, .yellow, .bottom)
    }
}