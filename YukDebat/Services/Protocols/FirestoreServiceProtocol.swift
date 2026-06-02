//
//  FirestoreServiceProtocol.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

// MARK: - Database - Protocols

import Foundation

/// Contract for cloud database (Firestore) operations.
protocol FirestoreServiceProtocol {
    
    /// Saves a document to the specified collection.
    func saveDocument(collection: String, documentId: String, data: [String: Any]) async throws
    
    /// Performs an atomic update on a document.
    func updateTransactional(collection: String, documentId: String, data: [String: Any]) async throws
    
    /// Removes a document from the specified collection.
    func deleteDocument(collection: String, documentId: String) async throws
    
    /// Attaches a live listener to a specific document.
    func attachSnapshotListener(collection: String, documentId: String, completion: @escaping (Result<[String: Any], Error>) -> Void)
}
