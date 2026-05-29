//
//  LocalCoreDataStorage.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

class LocalCoreDataStorage: CoreDataStorageProtocol {
    func saveLocalDraft(noteId: String, title: String, content: String) async throws {
        print("Mock CoreData: Draft \(noteId) autosaved locally.")
    }
    
    func executeLRUEviction(maxSizeInBytes: Int) throws {
        print("Mock CoreData: LRU Eviction checked for memory limit.")
    }
}
