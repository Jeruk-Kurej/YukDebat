//
//  LocalCoreDataStorage.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

// MARK: - Persistence - Mocks

import Foundation

/// Mock implementation for local storage persistence.
class CoreDataStorageMock: CoreDataStorageProtocol {
    
    func saveLocalDraft(noteId: String, title: String, content: String) async throws {
        print("Mock CoreData: Draft \(noteId) saved locally.")
    }
    
    func executeLRUEviction(maxSizeInBytes: Int) throws {
        print("Mock CoreData: Memory limit check executed.")
    }
}
