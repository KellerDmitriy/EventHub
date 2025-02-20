//
//  ScrollViewWithStickyHeader.swift
//  ScrollKit
//
//  Created by Daniel Saidi on 2023-02-03.
//  Copyright © 2023-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

struct ScrollViewWithStickyHeader<Header: View, Content: View>: View {

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
            navbarOverlay
        }
        .onAppear {
            setupNavigationBarAppearance()
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

    /// Убираем фон у `UINavigationBar` на iOS 15
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}


