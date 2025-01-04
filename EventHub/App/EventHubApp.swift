//
//  EventHubApp.swift
//  EventHub
//
//  Created by Денис Гиндулин on 16.11.2024.
//

import SwiftUI
import FirebaseCore

@main
struct EventHubApp: App {
    
    @StateObject private var coreDataManager = CoreDataManager()
    
    //MARK: - INIT
    init() {
        FirebaseApp.configure()
        
        DIContainer.register({ UserService() }, forKey: .userService, lifecycle: .transient)
        DIContainer.register({ AuthService() }, forKey: .authService, lifecycle: .singleton)
        DIContainer.register({ UDStorageService() as IStorageService}, forKey: .storageService, lifecycle: .singleton)
        DIContainer.register({ EventAPIService() as IEventAPIService }, forKey: .networkService, lifecycle: .singleton)
    }
    
    //MARK: - BODY
    var body: some Scene {
        WindowGroup {
            StartRouterView()
                .preferredColorScheme(.dark)
                .environmentObject(coreDataManager)
        }
    }
}
