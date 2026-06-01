//
//  MockCloudStorage.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//
import Foundation

/// Mock implementation for cloud blob media storage.
class MockCloudStorage: CloudStorageProtocol {

    // MARK: - Methods

    /// Memenuhi kontrak protokol dengan nama fungsi yang tepat: uploadImage
    func uploadImage(imageData: Data) async throws -> String {
        // Simulasi latensi jaringan
        try await Task.sleep(nanoseconds: 500_000_000)

        return
            "https://dummy-storage.com/posters/poster_\(UUID().uuidString).jpg"
    }
}
