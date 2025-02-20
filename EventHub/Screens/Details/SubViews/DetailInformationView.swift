//
//  DetailInformationView.swift
//  EventHub
//
//  Created by Даниил Сивожелезов on 30.11.2024.
//

import SwiftUI

struct DetailInformationView: View {
    let title: String
    let startDate: String
    let endDate: String
    let adress: String
    let location: String
    let bodyText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .airbnbCerealFont(.book, size: 25)
            
            DetailComponentView(image: Image(systemName: "calendar"),
                                title: startDate,
                                description: endDate)
            
            DetailComponentView(image: Image(.location),
                                title: adress,
                                description: location)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("About Event")
                    .airbnbCerealFont(.medium, size: 18)
                Text(bodyText)
                    .airbnbCerealFont(.book)
            }
            .padding(.top, 16)
        }
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.clear)
    }
}
