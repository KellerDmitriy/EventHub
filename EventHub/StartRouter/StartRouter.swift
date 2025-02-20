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
    
    private var storage: IStorageService
    private let authManager: IAuthService
    
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
    init(
        storage: IStorageService = DIContainer.resolve(forKey: .storageService) ?? UDStorageService(),
        authManager: IAuthService = DIContainer.resolve(forKey: .authService) ?? AuthService()
    ) {
        self.storage = storage
        self.authManager = authManager
        
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
        guard storage.hasCompleteOnboarding else {
            storage.hasCompleteOnboarding = true
            return .onboarding
        }
        let isAuthenticated = authManager.isAuthenticated()
        let isRememberMeOn = storage.isRememberMeOn
        
        return isAuthenticated && isRememberMeOn ? .main : .auth
    }
}
