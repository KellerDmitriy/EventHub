//
//  IFirebaseStorageService.swift
//  EventHub
//
//  Created by Келлер Дмитрий on 10.12.2024.
//


import SwiftUI
import FirebaseStorage

// MARK: - FirebaseStorageServiceProtocol
protocol IFirebaseStorageService {
    func getUrlForImage(path: String) async throws -> URL
    func getData(userID: String, path: String) async throws -> Data
    func getImage(userID: String, path: String) async throws -> UIImage
    func saveImage(data: Data, userID: String) async throws -> (path: String, name: String)
    func deleteImage(path: String) async throws
}

// MARK: - FirebaseStorageService
final class FirebaseStorageService: IFirebaseStorageService {
    
    // MARK: - Private Properties
    private let storage = Storage.storage().reference()
    
    // MARK: - Computed Properties
    /// Reference to the images folder in Firebase Storage
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    // MARK: - Private Methods
    
    /// Returns a reference to a user's folder in Firebase Storage
    /// - Parameter userID: The user's unique identifier
    /// - Returns: A StorageReference pointing to the user's folder
    private func userReference(userID: String) -> StorageReference {
        storage.child("users").child(userID)
    }
    
    func getPathForImage(path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }
    
    // MARK: - Public Methods
    
    /// Retrieves the download URL for an image stored in Firebase Storage
    /// - Parameter path: The path to the image in Firebase Storage
    /// - Returns: The download URL of the image
    func getUrlForImage(path: String) async throws -> URL {
        try await getPathForImage(path: path).downloadURL()
    }
    
    /// Retrieves the data for a specific file stored in Firebase Storage
    /// - Parameters:
    ///   - userID: The user's unique identifier
    ///   - path: The path to the file in Firebase Storage
    /// - Returns: The file data as `Data`
    func getData(userID: String, path: String) async throws -> Data {
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024) // 3 MB size limit
    }
    
    /// Retrieves an image from Firebase Storage and converts it to `UIImage`
    /// - Parameters:
    ///   - userID: The user's unique identifier
    ///   - path: The path to the image in Firebase Storage
    /// - Returns: The image as `UIImage`
    func getImage(userID: String, path: String) async throws -> UIImage {
        let data = try await getData(userID: userID, path: path)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        return image
    }
    
    /// Saves image data to Firebase Storage and returns the storage path and file name
    /// - Parameters:
    ///   - data: The image data to save
    ///   - userID: The user's unique identifier
    /// - Returns: The storage path and file name of the saved image
    func saveImage(data: Data, userID: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(userID: userID).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        return (returnedPath, returnedName)
    }
    
    func deleteImage(path: String) async throws {
        try await getPathForImage(path: path).delete()
    }
}
