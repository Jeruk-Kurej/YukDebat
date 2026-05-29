//
//  MockCloudStorage.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

class MockCloudStorage: CloudStorageProtocol {
    func uploadPosterFile(fileData: Data) async throws -> String {
            try await Task.sleep(nanoseconds: 500_000_000)
            return "https://dummy-storage.com/posters/poster_\(UUID().uuidString).jpg"
        }
    
    func deletePosterFile(fileUrl: String) async throws {
        print("Mock: Deleted poster at \(fileUrl)")
    }
}
