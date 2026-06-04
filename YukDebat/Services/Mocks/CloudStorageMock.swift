//
//  MockCloudStorage.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

// MARK: - CloudStorage - Mocks

import Foundation

/// Mock implementation for testing media uploads without real network usage.
class CloudStorageMock: CloudStorageServiceProtocol {
    
    func uploadImage(imageData: Data) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        return "https://dummy-storage.com/posters/poster_\(UUID().uuidString).jpg"
    }
}
