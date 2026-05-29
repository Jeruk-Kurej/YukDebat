//
//  CoreDataStorageProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

protocol CoreDataStorageProtocol {
    func saveLocalDraft(noteId: String, title: String, content: String) async throws
    func executeLRUEviction(maxSizeInBytes: Int) throws
}
