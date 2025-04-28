//
//  SuggestionRow.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 28.03.2025.
//

import SwiftUI

struct SuggestionRow: View {
    
    var title: String
    
    var body: some View {
        HStack {
            Image(systemName: "fossil.shell.fill")
            Text(title)
                .foregroundColor(.titleFont)
            Spacer()
            Image(systemName: "chevron.forward")
        }
        .listRowBackground(Color.clear)
    }
}
