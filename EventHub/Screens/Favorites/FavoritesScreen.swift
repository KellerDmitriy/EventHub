//
//  BookmarksView.swift
//  EventHub
//
//  Created by Руслан on 18.11.2024.
//

import SwiftUI

struct FavoritesScreen: View {
    @EnvironmentObject private var coreDataManager: CoreDataManager
    @StateObject var viewModel: FavoritesViewModel
    @State private var showSearchFlow = false
    
    init() {
        self._viewModel = StateObject(wrappedValue: FavoritesViewModel())
    }
    
    var body: some View {
        VStack {
            Spacer()
            if coreDataManager.events.isEmpty {
                NoFavorites()
            } else {
                FavoriteEventsList()
            }
            Spacer()
        }
        .background(.appBackground) 
        .background {
            NavigationLink(
                destination: SearchView(
                    searchScreenType: .withData,
                    localData: coreDataManager.events.map { ExploreModel(event: $0) }
                ),
                isActive: $showSearchFlow,
                label: { EmptyView() }
            )
        }
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                ToolBarTitleView(title: Resources.Text.favorites.localized)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                ToolBarButton(action: ToolBarAction(
                    icon: ToolBarButtonType.search.icon,
                    action: { showSearchFlow = true },
                    hasBackground: false,
                    foregroundStyle: Color.appBlue
                )
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FavoritesScreen()
        .environmentObject(CoreDataManager())
}
