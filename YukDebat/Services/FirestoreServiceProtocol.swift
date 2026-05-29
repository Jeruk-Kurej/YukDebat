//
//  FirestoreServiceProtocol.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import Foundation

protocol FirestoreServiceProtocol {
    func saveDocument(collection: String, documentId: String, data: [String: Any]) async throws
    func updateTransactional(collection: String, documentId: String, data: [String: Any]) async throws
    func deleteDocument(collection: String, documentId: String) async throws
    func attachSnapshotListener(collection: String, documentId: String, completion: @escaping (Result<[String: Any], Error>) -> Void)
}
