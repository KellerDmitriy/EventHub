//
//  UserService.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 10.12.2024.
//

import Foundation
import FirebaseFirestore

protocol IUserService {
    func createNewUser(_ user: DBUser) async throws
    func getUser(userId: String) async throws -> DBUser
    
    func updateUserName(_ name: String, userID: String) async throws
    func updateUserEmail(_ email: String, userID: String) async throws
    func updateUserInformations(_ info: String, userID: String) async throws 
    func updateUserProfileImage(name: String, userId: String) async throws
}

// MARK: - UserService
// A service class responsible for handling user-related operations with Firestore
final class UserService: IUserService {
    // MARK: - Properties
    // Reference to the "users" collection in Firestore
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    // MARK: - Private Methods
    // Returns a reference to a specific user document in the Firestore collection
    private func userDocument(_ userId: String) -> DocumentReference {
        guard !userId.isEmpty else {
            fatalError("User ID cannot be empty.")
        }
        return userCollection.document(userId)
    }
    
    // MARK: - Public Methods
    // Creates a new user in the Firestore database
    func createNewUser(_ user: DBUser) async throws {
        try userDocument(user.userID).setData(from: user, merge: false)
    }
    
    // Retrieves a user from the Firestore database
    func getUser(userId: String) async throws -> DBUser {
        do {
            // Получение документа пользователя из коллекции "users"
            let document = try await userDocument(userId).getDocument()
            
            // Проверка наличия данных в документе
            guard let data = document.data() else {
                print("No data found for user with ID: \(userId)")
                throw URLError(.dataNotAllowed)
            }
            
            guard let name = data["name"] as? String else {
                print("Поле 'name' не найдено в документе.")
                throw URLError(.dataNotAllowed)
            }
            
            guard let email = data["email"] as? String else {
                print("Поле 'email' не найдено в документе.")
                throw URLError(.dataNotAllowed)
            }
            
            guard let info = data["info"] as? String else {
                print("Поле 'info' не найдено в документе.")
                throw URLError(.dataNotAllowed)
            }
            
            guard let profileImageName = data["profile_image_name"] as? String else {
                print("Поле 'info' не найдено в документе.")
                throw URLError(.dataNotAllowed)
            }
            
            let dbUser = DBUser(userID: document.documentID, name: name, email: email, userInfo: info, profileImageName: profileImageName)
            
            print("Successfully fetched user: \(dbUser)")
            return dbUser
        } catch {
            print("Error fetching user data: \(error)")
            throw error
        }
    }
    
    // Updates the user's name in the Firestore database
    func updateUserName(_ name: String, userID: String) async throws {
        let data: [String : Any] = [DBUser.CodingKeys.name.rawValue : name]
        try await userDocument(userID).updateData(data)
    }
    
    // Updates the user's email in the Firestore database
    func updateUserEmail(_ email: String, userID: String) async throws {
        let data: [String : Any] = [DBUser.CodingKeys.email.rawValue : email]
        try await userDocument(userID).updateData(data)
    }
    
    // Updates the user's Informations in the Firestore database
    func updateUserInformations(_ info: String, userID: String) async throws {
        let data: [String : Any] = [DBUser.CodingKeys.info.rawValue : info]
        try await userDocument(userID).updateData(data)
    }
    
    // Updates the user's profile image name in the Firestore database
    func updateUserProfileImage(name: String, userId: String) async throws  {
        let data: [String : Any] = [DBUser.CodingKeys.profileImageName.rawValue : name]
        try await userDocument(userId).updateData(data)
    }
}
