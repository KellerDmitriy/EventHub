//
//  SearchBarView.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 20.11.2024.
//

import SwiftUI

struct CustomSearchBarView: View {
    @Binding var isSearchPresented: Bool
    @Binding var searchText: String
    
    let textColor: Color = .appForegroundStyle
    let magnifierColor: Color = .white
    
    let shouldHandleTextInput: Bool
    let fiterAction: (DisplayOrderType) -> Void
    let placeholderColor: Color = .searchBarPlaceholder
    
    var body: some View {
        HStack {
            Button {
                isSearchPresented.toggle()
            } label: {
                Image(.searchWhite)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing,10)
                    .foregroundStyle(magnifierColor)
            }
            
            Rectangle()
                .frame(width: 1, height: 20)
                .foregroundStyle(placeholderColor)
            if shouldHandleTextInput {
                TextField("", text: $searchText)
                    .airbnbCerealFont( AirbnbCerealFont.book, size: 18)
                    .tint(textColor)
                    .foregroundStyle(textColor)
                    .placeholder(when: searchText.isEmpty) {
                        Text("Search...").foregroundColor(placeholderColor)
                    }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .airbnbCerealFont( AirbnbCerealFont.book, size: 18)
                            .foregroundStyle(textColor)
                    }
                }
            } else {
                TextField("", text: .constant(""))
                    .airbnbCerealFont( AirbnbCerealFont.book, size: 18)
                    .tint(textColor)
                    .foregroundStyle(textColor)
                    .placeholder(when: searchText.isEmpty) {
                        Text("Search...").foregroundColor(placeholderColor)
                    }
                    .disabled(true)
                    .onTapGesture {
                        isSearchPresented = true
                    }
            }
            FiltersButton(filterAction: fiterAction)
        }
    }
}

#Preview {
    CustomSearchBarView(
        isSearchPresented: .constant(false),
        searchText: .constant(""),
        shouldHandleTextInput: true,
    fiterAction: { _ in }
        )
}
