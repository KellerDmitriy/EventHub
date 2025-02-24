//
//  ScrollOffsetKey.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 24.02.2025.
//
import SwiftUI

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let newValue = nextValue()
    }
}
