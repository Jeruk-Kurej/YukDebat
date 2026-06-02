//
//  MockFirestoreService.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

// MARK: - Database - Mocks

import Foundation

/// Mock implementation of Firestore operations for UI testing.
class FirestoreServiceMock: FirestoreServiceProtocol {
    
    func saveDocument(collection: String, documentId: String, data: [String: Any]) async throws {
        print("Mock: Saved document to \(collection)/\(documentId)")
    }
    
    func updateTransactional(collection: String, documentId: String, data: [String: Any]) async throws {
        print("Mock: Transactional update executed on \(documentId)")
    }
    
    func deleteDocument(collection: String, documentId: String) async throws {
        print("Mock: Deleted document from \(collection)/\(documentId)")
    }
    
    func attachSnapshotListener(collection: String, documentId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Mengirim data dummy untuk mengisi UI saat testing
        let dummyData: [String: Any] = [
            "id": documentId,
            "hostId": "user_preview_123",
            "motionTitle": "Preview Mosi Debat",
            "state": "PREPARING"
        ]
        completion(.success(dummyData))
    }
}
