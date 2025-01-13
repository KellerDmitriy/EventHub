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
        ZStack {
            VStack {
                TabContent(selectedTab: selectedTab, router: router)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.bottom, 88)
            VStack {
                Spacer()
                TabBarView(
                    selectedTab: $selectedTab,
                    switchTab: switchTab
                )
                .padding(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
                .background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea(.all)
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

#Preview {
    EventHubContentView(router: StartRouter())
}
