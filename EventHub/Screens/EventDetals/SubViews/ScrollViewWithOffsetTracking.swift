//
//  ScrollViewWithOffsetTracking.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 24.12.2024.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0.0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollViewWithCollapsibleHeader<Content: View>: View {
    let content: () -> Content
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { outerProxy in
            ScrollView {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        content()
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(
                                            key: ScrollOffsetPreferenceKey.self,
                                            value: proxy.frame(in: .global).minY
                                        )
                                }
                            )
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                offset = value
                            }
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}
