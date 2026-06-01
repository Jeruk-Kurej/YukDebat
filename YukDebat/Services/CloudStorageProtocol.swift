//
//  CloudStorageProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

/// Defines the contract for uploading media files to a remote cloud storage service.
/// Fulfills the Dependency Inversion Principle allowing easy switching between Cloudinary, Firebase Storage, or Mocks.
protocol CloudStorageProtocol {
    
    /// Uploads raw image data and returns the secure URL of the hosted image.
    func uploadImage(imageData: Data) async throws -> String
}
