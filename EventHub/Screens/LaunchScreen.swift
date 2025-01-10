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
        ZStack  {
            Color.appBackground
            
            Image(.logo)
                .onAppear(perform: routeToStart)
        }
       
        .ignoresSafeArea(.all)
    }
    
    func routeToStart() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            router.updateRouterState(with: .launchCompleted)
        }
    }
}

#Preview {
    LaunchScreen(router: StartRouter())
}
