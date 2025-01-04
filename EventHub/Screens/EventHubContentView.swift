//
//  ContentView.swift
//  EventHub
//
//  Created by Денис Гиндулин on 16.11.2024.
//

import SwiftUI

struct EventHubContentView: View {
    @State private var selectedTab: Tab = .explore
    private let router: StartRouter

    init(router: StartRouter) {
        self.router = router
    }

    func switchTab(_ tab: Tab) {
        selectedTab = tab
    }

    var body: some View {
        VStack(spacing: 0) {
            TabContent(selectedTab: selectedTab, router: router)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.top)
            
            TabBarView(selectedTab: $selectedTab, switchTab: switchTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabContent: View {
    let selectedTab: Tab
    let router: StartRouter

    var body: some View {
        NavigationView {
            Group {
                switch selectedTab {
                case .explore:
                    ExploreScreen()
                case .events:
                    EventsScreen()
                case .map:
                    MapScreen()
                case .favorites:
                    FavoritesScreen()
                case .profile:
                    ProfileScreen(router: router)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
