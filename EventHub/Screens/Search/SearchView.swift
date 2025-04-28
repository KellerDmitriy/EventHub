//
//  SearchView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 28.11.2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    
    @State private var showSuggestions = true
    
    // MARK: - Init
    init(searchScreenType: SearchScreenType,
         localData: [ExploreModel] = []
    ) {
        self._viewModel = StateObject(wrappedValue: SearchViewModel(searchScreenType: searchScreenType, localData: localData))
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            CustomSearchBarView(
                isSearchPresented: $showSuggestions,
                searchText: $viewModel.searchText,
                shouldHandleTextInput: true,
                fiterAction: {_ in }
            )
            .onChange(of: viewModel.searchText) { newValue in
                if viewModel.searchText.isEmpty {
                    showSuggestions = true
                }
            }
            
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .zIndex(1)
            
            if showSuggestions {
                suggestionsContent
                    .padding(.top, 12)
            } else  if !viewModel.searchResults.isEmpty {
                searchResultsContent
                    .padding(.top, 12)
            } else {
                noResultsContent
                    .padding(.top, 300)
            }
            Spacer()
        }
        
        .background(Color.appBackground)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackBarButtonView()
            }
            ToolbarItem(placement: .principal) {
                ToolBarTitleView(
                    title: Resources.Text.search.localized
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Content Views
    private var searchResultsContent: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(viewModel.searchResults) { event in
                    NavigationLink(destination: DetailsScreen(detailID: event.id)) {
                        SmallEventCard(
                            image: event.image ?? "",
                            date: event.eventDate,
                            title: event.title,
                            place: event.address ?? "",
                            showPlace: false
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 5)
                    }
                }
            }
        }
    }
    
    private var noResultsContent: some View {
        Text("No results".uppercased())
            .airbnbCerealFont(AirbnbCerealFont.bold, size: 26)
    }
    
    private var suggestionsContent: some View {
        List {
            ForEach(viewModel.getSuggestions(), id: \.self) { suggestion in
                
                SuggestionRow(title: suggestion)
                    .onTapGesture {
                        viewModel.searchText = suggestion
                        viewModel.addToReрcents()
                        showSuggestions = false
                    }
            }
            .onDelete { indexSet in
                viewModel.removeRecentSearch(at: indexSet)
            }
        }
        
        .frame(height: getHightForSuggestonsList())
        .padding(.top, 12)
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
    
    
    // MARK: - Helpers Methods
    private func getHightForSuggestonsList() -> CGFloat {
        let rowHeight: CGFloat = 44
        let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.25
        let calculatedHeight = CGFloat(viewModel.getSuggestions().count) * rowHeight
        
        return min(calculatedHeight, maxHeight)
    }
}

#Preview {
    NavigationView {
        SearchView(searchScreenType: .withoutData)
    }
}

