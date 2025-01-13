//
//  ProfileViewModel.swift
//  EventHub
//
//  Created by Руслан on 18.11.2024.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    private let router: StartRouter
    
    private let authService: IAuthService
    private let userService: IUserService
    
    @Published private(set) var currentUser: DBUser? = nil
    
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userInfo: String = ""
    @Published var profileImageName: String = ""
    
    @Published var error: ProfileError? = nil
    
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
    
    // MARK: - Methods
    func showLogoutAlert() { error = .logout }
    func cancelErrorAlert() { error = nil }
    
    func tapErrorOk() {
        switch error {
        case .logout:
            logOut()
        default: return
        }
    }
    
    //    MARK: - AuthService Methods
    func loadCurrentUser() async {
        do {
            let authDataResult = try authService.getAuthenticatedUser()
            self.currentUser = try await userService.getUser(userId: authDataResult.uid)
            if let currentUser = currentUser {
                userName = currentUser.name
                userEmail = currentUser.email
                userInfo = currentUser.userInfo
                profileImageName = currentUser.profileImageName
            }
        } catch {
            self.error = ProfileError.map(error)
        }
    }
    
    func updateProfileInformation() async {
          guard let userID = currentUser?.userID else { return }
          do {
              try await userService.updateUserEmail(userEmail, userID: userID)
              try await userService.updateUserName(userName, userID: userID)
              try await userService.updateUserInformations(userInfo, userID: userID)
              try await userService.updateUserProfileImage(name: profileImageName, userId: userID)
          } catch {
              self.error = ProfileError.map(error)
          }
      }
    
    
    func logOut() {
        do {
            try authService.signOut()
            openApp()
        } catch {
            self.error = ProfileError.map(error)
        }
    }
    
    func openApp() {
        router.updateRouterState(with: .userLoggedOut)
    }
}
