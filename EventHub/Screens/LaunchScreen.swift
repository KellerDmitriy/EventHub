//
//  LaunchScreen.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 08.01.2025.
//

import SwiftUI

struct LaunchScreen: View {
    let router: StartRouter
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    func routeToStart() {
        router.updateRouterState(with: .launchCompleted)
    }
}

#Preview {
    LaunchScreen(router: StartRouter())
}
