//
//  DetailInformationView.swift
//  EventHub
//
//  Created by Даниил Сивожелезов on 30.11.2024.
//

import SwiftUI

struct DetailInformationView: View {

    let startDate: String
    let endDate: String
    let adress: String
    let location: String
    let agentTitle: String
    let role: String
    let bodyText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            VStack(alignment: .leading, spacing: 24) {
                DetailComponentView(
                    image: Image(systemName: "calendar"),
                    title: startDate,
                    description: endDate
                )
                
                DetailComponentView(
                    image: Image(.location),
                    title: adress,
                    description: location
                )
                
                DetailComponentView(
                    image: Image(.avatar),
                    title: agentTitle,
                    description: role,
                    showImgBg: false
                )
            }
            
            Text("About Event")
                .airbnbCerealFont(.medium, size: 18)
            Text(bodyText)
                .airbnbCerealFont(.book)
        }
        .padding(.horizontal, 20)
        .padding(.top, 35)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .padding(.top, -30)
    }
}
