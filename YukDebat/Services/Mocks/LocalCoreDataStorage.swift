//
//  LocalCoreDataStorage.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
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
