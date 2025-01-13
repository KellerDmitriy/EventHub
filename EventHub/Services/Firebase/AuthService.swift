//
//  AuthService.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 10.12.2024.
//


import Foundation
import FirebaseAuth
import Firebase
import GoogleSignIn

protocol IAuthService {
    func isAuthenticated() -> Bool
    func getAuthenticatedUser() throws -> AuthDataResultModel
    func signOut() throws
    func delete() async throws
    func createUser(email: String, password: String) async throws -> AuthDataResultModel
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel
    func resetPassword(email: String) async throws
    func updateEmail(email: String) async throws
    func signInWithGoogle() async throws -> AuthDataResultModel
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel
}

// MARK: - AuthService
final class AuthService: IAuthService {
    
    // MARK: - Methods
    func isAuthenticated() -> Bool {
        return Auth.auth().currentUser?.uid != nil
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
  
    
    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        try await user.delete()
    }
}

// MARK: SIGN IN EMAIL
extension AuthService {
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        try await authDataResult.user.sendEmailVerification()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }

    @discardableResult
    func signInWithGoogle() async throws -> AuthDataResultModel {
        // Настройка конфигурации Google Sign-In
        configureGoogleSignIn()

        // Получение rootViewController
        let rootViewController = try await getRootViewController()

        // Авторизация через Google
        let gidSignInResult = try await signInWithGoogle(using: rootViewController)

        // Получение токенов Google
        let tokens = try getGoogleTokens(from: gidSignInResult)

        // Создание учетных данных Firebase и вход в систему
        return try await signInToFirebase(with: tokens)
    }

    // Настройка конфигурации Google Sign-In
    private func configureGoogleSignIn() {
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
    }

    // Получение rootViewController для представления экрана входа в Google
    private func getRootViewController() async throws -> UIViewController {
        let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = await scene?.windows.first?.rootViewController else {
            fatalError("There is no root view controller!")
        }
        return rootViewController
    }

    // Авторизация через Google и получение результата
    private func signInWithGoogle(using rootViewController: UIViewController) async throws -> GIDSignInResult {
        return try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
    }

    // Получение токенов Google из результата авторизации
    private func getGoogleTokens(from gidSignInResult: GIDSignInResult) throws -> GoogleSignInResultModel {
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        return GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
    }

    // Создание учетных данных Firebase и вход в систему
    private func signInToFirebase(with tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }

    // Вход в систему Firebase с использованием учетных данных
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
