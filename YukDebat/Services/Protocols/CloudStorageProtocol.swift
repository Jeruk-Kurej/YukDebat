//
//  CloudStorageProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

// MARK: - CloudStorage - Protocols

import Foundation

/// Contract for media upload operations to remote cloud storage.
protocol CloudStorageProtocol {
    
    /// Uploads raw data and returns the secure resource URL.
    func uploadImage(imageData: Data) async throws -> String
}
