//
//  CustomToolbar.swift
//  EventHub
//
//  Created by Marat Fakhrizhanov on 20.11.2024.
//

import SwiftUI

struct ExploreToolBar: View {
    
    //     MARK: - Properties
    private let searchText: String = ""
    
    @Binding var currentLocation: String
    @Binding var title: String
    @Binding var isSearchPresented: Bool
    
    let isNotifications: Bool
    let filterAction: (DisplayOrderType) -> Void
    let textColor: Color = .white
    let locations: [EventLocation]
    
    //    MARK: - Body
    var body: some View {
        VStack {
            topBar
                .padding(.top, 35)
            searchBar
        }
        .frame(height: 179)
        .frame(maxWidth: .infinity)
        .background(.appBlue)
        .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft,.bottomRight]))
    }
    
    //    MARK: - Top Bar
    private var topBar: some View {
        HStack {
            locationMenu
              
            Spacer()
            notificationButton
        }
        
        .padding(.horizontal, 24)
        .padding(.bottom, 2)
    }
    
    //    MARK: - LocationMenu
    private var locationMenu: some View {
        VStack(alignment: .leading) {
            Menu {
                ForEach(locations, id: \.name) { location in
                    Button {
                        currentLocation = location.slug
                        title = location.name ?? "no location name"
                    } label: {
                        Text(location.name ?? "no location name")
                    }
                }
            } label: {
                Text("Current Location")
                    .airbnbCerealFont( AirbnbCerealFont.book, size: 14)
                    .frame(
                        width: 120,
                        height: 16,
                        alignment: .leading
                    )
                    .foregroundStyle(Color.white)
                    .opacity(0.7)
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 10, height: 5)
                    .foregroundStyle(Color.white)
                    .opacity(0.7)
            }
            
            Text(title)
                .foregroundStyle(Color.white)
                .airbnbCerealFont(AirbnbCerealFont.bold, size: 15)
        }
    }
    
    //    MARK: - NotificationButton
    private var notificationButton: some View {
        Button {
            // show natifications
        } label: {
            ZStack {
                Rectangle()
                    .foregroundStyle(.filterButton)
                
                ZStack(alignment: .topTrailing) {
                    Image(.notificationsBell)
                        .resizable()
                        .frame(width: 15, height: 16)
                    
                    if isNotifications {
                        Image(.notificationsDot)
                            .resizable()
                            .frame(width: 5, height: 5)
                    }
                }
            }
            .clipShape(Circle())
            .frame(width: 36, height: 36)
        }
    }
    
    //    MARK: - Search Bar
    private var searchBar: some View {
        SearchBarViewForMap (
            isSearchPresented: $isSearchPresented,
            searchText: .constant(searchText),
            shouldHandleTextInput: false,
            fiterAction: filterAction
        )
        .padding(.horizontal,24)
    }
}

// MARK: - Preview
#Preview {
    ExploreToolBar(
        currentLocation: .constant("City "),
        title: .constant("City "),
        isSearchPresented: .constant(true),
        isNotifications: true,
        filterAction: {_ in },
        locations: []
    )
}
