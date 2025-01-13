//
//  SearchView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 28.11.2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    
    @State private var isSearchPresented = true
    
    // MARK: - Init
    init(searchScreenType: SearchScreenType,
         localData: [ExploreModel] = []
    ) {
        self._viewModel = StateObject(wrappedValue: SearchViewModel(searchScreenType: searchScreenType, localData: localData))
    }
    
    // MARK: - Body
    var body: some View {
            VStack(spacing: 0) {
                    SearchBarViewForMap(
                      isSearchPresented: $isSearchPresented,
                      searchText: $viewModel.searchText,
                      textColor: .appForegroundStyle,
                      magnifierColor: .appBlue,
                      shouldHandleTextInput: true,
                      fiterAction: {_ in }
                    )
                    .padding(.horizontal,24)
                    .padding(.top, 10)
                .zIndex(1)
                Spacer()
                
                if viewModel.searchResults.isEmpty {
                    Text("No results".uppercased())
                        .airbnbCerealFont(AirbnbCerealFont.bold, size: 26)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            ForEach(viewModel.searchResults) { event in
                                NavigationLink(destination: DetailView(detailID: event.id)) {
                                    SmallEventCard(
                                        image: event.image ?? "",
                                        date: event.date,
                                        title: event.title,
                                        place: event.adress,
                                        showPlace: false
                                    )
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 5)
                                }
                            }
                        }
                    }
            }
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
}

#Preview {
    SearchView(searchScreenType: .withoutData)
}
