//
//  AuthViewModel.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 10.12.2024.
//


import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseAuthCombineSwift
import GoogleSignIn

enum AuthStatus {
    case authenticated
    case unauthenticated
    case authenticating
}

enum AuthenticationError: LocalizedError, Equatable {
    case tokenError(message: String)
    case validationError
    case validationSignUpError
    case signInError(error: Error)
    case signUpError(error: Error)
    case signUpSuccess
    case customError(message: String)
    
    static func == (lhs: AuthenticationError, rhs: AuthenticationError) -> Bool {
        switch (lhs, rhs) {
        case (.validationError, .validationError),
            (.validationSignUpError, .validationSignUpError),
            (.signUpSuccess, .signUpSuccess):
            return true
        case (.signInError, .signInError),
            (.signUpError, .signUpError):
            return true
        case (.customError(let lhsMessage), .customError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
    
    var failureReason: String? {
        switch self {
        case .validationError:
            return "Incorrect form input."
        case .validationSignUpError:
            return "The signup form is invalid."
        case .signInError(let error):
            return "Sign in failed: \(error.localizedDescription)"
        case .signUpError(let error):
            return "Sign up failed: \(error.localizedDescription)"
        case .customError(let message):
            return message
        case .signUpSuccess:
            return "Sign Up was successful"
        case .tokenError(message: let message):
            return message
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .validationError:
            return "Please fill all fields correctly."
        case .validationSignUpError:
            return "Please ensure all fields are correct and passwords match."
        case .signInError(let error):
            return error.localizedDescription
        case .signUpError(let error):
            return error.localizedDescription
        case .customError(let message):
            return message
        case .signUpSuccess:
            return "Your account has been created successfully."
        case .tokenError(message: let message):
            return message
        }
    }
}


@MainActor
final class AuthViewModel: ObservableObject{
    
    private let authService: IAuthService
    private let userService: IUserService
    private let router: StartRouter
    
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    
    
    @Published var authenticationState: AuthStatus = .unauthenticated
    @Published var authError: AuthenticationError?
    
    @Published var isLoading: Bool = false
    
    var formIsValid: Bool {
        return !email.isEmpty && !password.isEmpty && password.count >= 5 && !password.contains(" ")
    }
    
    var signUpFormIsValid: Bool {
        return !email.isEmpty &&
        password.count >= 5 &&
        password == confirmPassword &&
        !name.isEmpty &&
        !password.contains(" ") &&
        !email.contains(" ")
    }
    
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
    
    func cancelErrorAlert() {
        authError = nil
    }
    
    //MARK: - Sign In
    func signIn() async {
        guard formIsValid else {
            authError = .validationError
            return
        }
        do {
            try await authService.signInUser(email: email, password: password)
            routeToMainFlow()
        } catch {
            authError = .signInError(error: error)
        }
    }
    
    
    //MARK: - Sign Up
    func registerUser() async {
        guard signUpFormIsValid else {
            authError = .validationSignUpError
            return
        }
        
        do {
            var authDataResult = try await authService.createUser(email: email, password: password)
            authDataResult.userName = name
            let user = DBUser(auth: authDataResult)
            try await userService.createNewUser(user)
            
            authError = .signUpSuccess
        } catch {
            authError = .signUpError(error: error)
        }
    }
    
    //MARK: - Reset Password
    func resetPassword(email: String) async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("Password reset email sent to \(email)")
            return true
        } catch {
            authenticationState = .unauthenticated
            return false
        }
    }
    
    // MARK: Google
    func signInWithGoogle() async throws {
        do {
            let authDataResult = try await authService.signInWithGoogle()
            let user = DBUser(auth: authDataResult)
            try await userService.createNewUser(user)
            routeToMainFlow()
        } catch {
            authError = .signInError(error: error)
        }
    }
    //MARK: - NavigationState
    func routeToMainFlow() {
        router.updateRouterState(with: .userAuthorized)
    }
}
