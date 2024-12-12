//
//  ProfileViewModel.swift
//  EventHub
//
//  Created by Руслан on 18.11.2024.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    private let router: StartRouter
    
    private let authService: IAuthService
    private let userService: IUserService
    
    @Published private(set) var currentUser: DBUser? = nil
    
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userInfo: String = ""
    @Published var profileImageName: String = ""
    
    //    MARK: - INIT
    init(
        router: StartRouter,
        authService: IAuthService = DIContainer.resolve(forKey: .authService) ?? AuthService(),
        userService: IUserService = DIContainer.resolve(forKey: .userService) ?? UserService()
    ) {
        self.router = router
        self.authService = authService
        self.userService = userService
    }
    
    
    func loadCurrentUser() async throws {
        let authDataResult = try authService.getAuthenticatedUser()
        self.currentUser = try await userService.getUser(userId: authDataResult.uid)
        if let currentUser = currentUser {
            userName = currentUser.name
            userEmail = currentUser.email
            userInfo = currentUser.userInfo
            profileImageName = currentUser.profileImageName
        }
    }
    
    
    func signOut() {
        do {
            try authService.signOut()
            openApp()
        } catch {
            print("error SIGN OUT")
        }
    }
    
//    func updateUserProfile(name: String, info: String, image: String) {
//        guard let currentUser = currentUser else { return }
//        
//        let userId = currentUser.userID
//            let updatedData: [String: Any] = [
//                "name": name,
//                "image": image,
//                "info": info
//            ]
//            
//            firestoreManager.updateUserData(userId: userId, data: updatedData)
//        }
    
    func openApp() {
        router.updateRouterState(with: .userLoggedOut)
    }
    
}
