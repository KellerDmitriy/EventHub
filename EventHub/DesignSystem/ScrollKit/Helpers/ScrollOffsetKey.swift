//
//  ScrollOffsetKey.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 24.02.2025.
//
import SwiftUI
//


enum ScrollOffsetNamespace {
    static let namespace = "scrollView"
    static let exploreNamespace = "exploreNamespace"
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}
