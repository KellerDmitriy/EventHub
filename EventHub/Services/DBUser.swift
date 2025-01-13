//
//  GoogleSignInResultModel.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 10.12.2024.
//


import Foundation
import FirebaseAuth

// MARK: - GoogleSignInResultModel
// Model to store the result of a Google Sign-In, containing the ID and access tokens
struct GoogleSignInResultModel {
    let idToken: String       // The ID token returned by Google Sign-In
    let accessToken: String   // The access token returned by Google Sign-In
}

// MARK: - AuthDataResultModel
// Model to store authentication data, conforming to Codable for easy JSON encoding/decoding
struct AuthDataResultModel: Codable {
    let uid: String            // The unique identifier for the user
    var userName: String       // The user's display name
    let email: String          // The user's email address
    let info: String            // The user's Informations
    let profileImageName: String  // The URL of the user's profile image name

    // MARK: - CodingKeys
    // Custom keys for encoding/decoding, in case the property names differ from the JSON keys
    enum CodingKeys: String, CodingKey {
        case uid
        case userName
        case email
        case info
        case profileImageName
    }
    
    // MARK: - Initializer
    // Initializes the model using a Firebase `User` object
    init(user: User) {
        self.uid = user.uid
        self.userName = user.displayName ?? ""
        self.email = user.email ?? ""
        self.info = ""
        self.profileImageName = user.photoURL?.absoluteString ?? ""
    }
}

// MARK: - DBUser
// Model representing a user stored in the database, conforming to Codable
struct DBUser: Codable {
    let userID: String              // The unique identifier for the user in the database
    let name: String                // The user's display name
    let email: String               // The user's email address
    let info: String            // The user's Informations
    let profileImageName: String // The URL to the user's profile image name


    // MARK: - Initializers

    // Initializes a DBUser using an AuthDataResultModel
    init(auth: AuthDataResultModel) {
        self.userID = auth.uid
        self.name = auth.userName
        self.email = auth.email
        self.info = auth.info
        self.profileImageName = auth.profileImageName
    }
    
    // Static method to provide a test instance of DBUser
    static func getTestDBUser() -> DBUser {
        return DBUser(
            userID: "",
            name: "",
            email: "",
            userInfo: "",
            profileImageName: ""
        )
    }
    
    // Custom initializer to create a DBUser with specified values
    init(
        userID: String,
        name: String,
        email: String,
        userInfo: String,
        profileImageName: String
    ) {
        self.userID = userID
        self.name = name
        self.email = email
        self.info = userInfo
        self.profileImageName = profileImageName
    }
    
    // MARK: - CodingKeys
    // Custom keys for encoding/decoding to handle different JSON keys
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"                   // Maps "user_id" JSON key to "userID" property
        case name = "name"
        case email = "email"
        case info = "info"
        case profileImageName = "profile_image_name" // Maps "profile_image_name" JSON key to "profileImageName" property
    }
    
    // Custom initializer for decoding JSON into a DBUser instance
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.info = try container.decodeIfPresent(String.self, forKey: .info) ?? ""
        self.profileImageName = try container.decodeIfPresent(String.self, forKey: .profileImageName) ?? "avatar"
    }
    
    // Method to encode a DBUser instance into JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userID, forKey: .userID)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.profileImageName, forKey: .profileImageName)
    }
}
