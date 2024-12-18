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
        guard !userId.isEmpty else {
            throw NSError(domain: "InvalidUserID", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID cannot be empty."])
        }
        return try await userDocument(userId).getDocument(as: DBUser.self)
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
        let data: [String : Any] = [DBUser.CodingKeys.userInfo.rawValue : info]
        try await userDocument(userID).updateData(data)
    }
    
    // Updates the user's profile image name in the Firestore database
    func updateUserProfileImage(name: String, userId: String) async throws  {
        let data: [String : Any] = [DBUser.CodingKeys.profileImageName.rawValue : name]
        try await userDocument(userId).updateData(data)
    }
}
