//
//  StartRouter.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 27.11.2024.
//


import Foundation
import FirebaseAuth

final class StartRouter: ObservableObject {
    // MARK: - Published Properties
    @Published var routerState: RouterState = .launch
    
    private let storage = DIContainer.resolve(forKey: .storageService) ?? UDStorageService()
    //    private let authManager = FirebaseManager.shared
    
    // MARK: - State & Event Enums
    enum RouterState {
        case launch
        case onboarding
        case auth
        case main
    }
    
    enum StartEvent {
        case launchCompleted
        case onboardingCompleted
        case userAuthorized
        case userLoggedOut
    }
    
    // MARK: - Initializer
    init() {
        updateRouterState(with: .launchCompleted)
    }
    
    // MARK: - State Management
    private func reduce(_ event: StartEvent) -> RouterState {
     
        switch event {
        case .onboardingCompleted: return rootState()
        case .userAuthorized: return .main
        case .userLoggedOut: return .auth
        case .launchCompleted: return rootState()
        }
    }
    
    // MARK: - Public Methods
    func updateRouterState(with event: StartEvent) {
        routerState = reduce(event)
    }
    
    // MARK: - Private Helpers
    private func rootState() -> RouterState {
        if storage.hasCompletedOnboarding() {
            if storage.getIsRememberMeOn() && Auth.auth().currentUser != nil {
                return .main
            } else {
                return (Auth.auth().currentUser != nil && !storage.getIsRememberMeOn()) ? .main : .auth
            }
        } else {
            storage.set(value: true as Bool, forKey: .hasCompletedOnboarding)
            return .onboarding
           
        }
    }
}
