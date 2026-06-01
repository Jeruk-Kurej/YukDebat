//
//  CloudStorageProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

/// Outlines media storage actions for uploading and removing large binary objects.
protocol CloudStorageProtocol {
    // MARK: - Methods
    func uploadPosterFile(fileData: Data) async throws -> String
    func deletePosterFile(fileUrl: String) async throws
}
