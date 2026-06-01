//
//  CoreDataStorageProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

/// Manages local persistent cache for robust offline-first case building mechanisms.
protocol CoreDataStorageProtocol {
    // MARK: - Methods
    func saveLocalDraft(noteId: String, title: String, content: String)
        async throws
    func executeLRUEviction(maxSizeInBytes: Int) throws
}
