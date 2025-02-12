//
//  ScrollViewWithStickyHeader.swift
//  ScrollKit
//
//  Created by Daniel Saidi on 2023-02-03.
//  Copyright © 2023-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

/// This scroll view lets you inject a header view that will
/// stick to the top when the view scrolls.
///
/// The view wraps a ``ScrollViewWithOffsetTracking`` to get
/// scroll offset that it then uses to determine how much of
/// the header that's below the navigation bar. It also uses
/// a ``ScrollViewHeader`` to make your header view properly
/// stretch out when the scroll view is pulled down.
///
/// You can use the `onScroll` init parameter to pass in any
/// function that should be called whenever the view scrolls.
/// The function is called with the scroll view offset and a
/// "header visible ratio", which indicates how much of your
/// header that is visible below the navigation bar.
///
/// This view will automatically use an inline title display
/// mode, since it doesn't work for a large nativation title.

struct ScrollViewWithStickyHeader<Header: View, Content: View>: View {

    /// Create a scroll view with a sticky header.
    ///
    /// - Parameters:
    ///   - axes: The scroll axes to use, by default `.vertical`.
    ///   - header: The scroll view header builder.
    ///   - headerHeight: The height to apply to the scroll view header.
    ///   - headerMinHeight: The minimum height to apply to the scroll view header, by default `nil`.
    ///   - showsIndicators: Whether or not to show scroll indicators, by default `true`.
    ///   - onScroll: An action that will be called whenever the scroll offset changes, by default `nil`.
    ///   - content: The scroll view content builder.
    init(
        _ axes: Axis.Set = .vertical,
        @ViewBuilder header: @escaping () -> Header,
        headerHeight: CGFloat,
        headerMinHeight: CGFloat? = nil,
        showsIndicators: Bool = true,
        onScroll: ScrollAction? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.header = header
        self.headerHeight = headerHeight
        self.headerMinHeight = headerMinHeight
        self.onScroll = onScroll
        self.content = content
    }

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let header: () -> Header
    private let headerHeight: CGFloat
    private let headerMinHeight: CGFloat?
    private let onScroll: ScrollAction?
    private let content: () -> Content

    typealias ScrollAction = (_ offset: CGPoint, _ headerVisibleRatio: CGFloat) -> Void

    @State
    private var navigationBarHeight: CGFloat = 0

    @State
    private var scrollOffset: CGPoint = .zero

    private var headerVisibleRatio: CGFloat {
        (headerHeight + scrollOffset.y) / headerHeight
    }

    var body: some View {
        ZStack(alignment: .top) {
            scrollView
//            navbarOverlay
        }

        .navigationBarTitleDisplayMode(.inline)
    }
}

@MainActor
private extension ScrollViewWithStickyHeader {
    
    var isStickyHeaderVisible: Bool {
        guard let headerMinHeight else { return headerVisibleRatio <= 0 }
        return scrollOffset.y < -headerMinHeight
    }

    @ViewBuilder
    var navbarOverlay: some View {
        if isStickyHeaderVisible {
            Color.clear
                .frame(height: navigationBarHeight)
                .overlay(scrollHeader, alignment: .bottom)
                .ignoresSafeArea(edges: .top)
                .frame(height: headerMinHeight)
        }
    }

    var scrollView: some View {
        GeometryReader { proxy in
            ScrollViewWithOffsetTracking(
                axes,
                showsIndicators: showsIndicators,
                onScroll: handleScrollOffset
            ) {
                VStack(spacing: 0) {
                    scrollHeader
                    content()
                        .frame(maxHeight: .infinity)
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    navigationBarHeight = proxy.safeAreaInsets.top
                }
            }
        }
    }

    var scrollHeader: some View {
        ScrollViewHeader(content: header)
            .frame(height: headerHeight)
    }

    func handleScrollOffset(_ offset: CGPoint) {
        self.scrollOffset = offset
        self.onScroll?(offset, headerVisibleRatio)
    }
}

#Preview {
    struct Preview: View {
        
        @State
        var selection = 0
        
        func header() -> some View {
                Color.red.tag(0)
        }
        
        var body: some View {
            ScrollViewWithStickyHeader(
                header: header,
                headerHeight: 250,
                headerMinHeight: 50,
                showsIndicators: true
            ) {
                LazyVStack {
                    ForEach(1...100, id: \.self) {
                        Text("\($0)")
                    }
                }
            }
        }
    }
    
    return NavigationView {
        #if os(macOS)
        Color.clear
        #endif
        Preview()
    }
    .colorScheme(.dark)
    .accentColor(.white)
    #if os(iOS)
    .navigationViewStyle(.stack)
    #endif
}


