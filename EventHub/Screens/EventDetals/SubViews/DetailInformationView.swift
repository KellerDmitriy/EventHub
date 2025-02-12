//
//  DetailInformationView.swift
//  EventHub
//
//  Created by Даниил Сивожелезов on 30.11.2024.
//

import SwiftUI

struct DetailInformationView: View {

    let bodyText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            Text("About Event")
                .airbnbCerealFont(.medium, size: 18)
            Text(bodyText)
                .airbnbCerealFont(.book)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        
    }
}
