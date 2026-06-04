//
//  CoreDataStorageServiceProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

// MARK: - Persistence - Protocols

import Foundation

/// Manages local persistent cache for offline-first capabilities.
protocol CoreDataStorageServiceProtocol {
    
    /// Persists a draft to local storage.
    func saveLocalDraft(noteId: String, title: String, content: String) async throws
    
    /// Cleans up local storage to maintain memory limits.
    func executeLRUEviction(maxSizeInBytes: Int) throws
}
