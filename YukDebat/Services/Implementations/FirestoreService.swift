//
//  FirestoreService.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

// MARK: - Firestore - Implementation

import FirebaseFirestore
import Foundation

class FirestoreService: FirestoreServiceProtocol {
    
    private let db = Firestore.firestore()
    
    // MARK: - Core Methods
    
    func saveDocument(collection: String, documentId: String, data: [String : Any]) async throws {
        try await db.collection(collection).document(documentId).setData(data, merge: true)
    }
    
    func updateTransactional(collection: String, documentId: String, data: [String : Any]) async throws {
        try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let ref = self.db.collection(collection).document(documentId)
            transaction.updateData(data, forDocument: ref)
            return nil
        }
    }
    
    func deleteDocument(collection: String, documentId: String) async throws {
        try await db.collection(collection).document(documentId).delete()
    }
    
    func attachSnapshotListener(collection: String, documentId: String, completion: @escaping (Result<[String : Any], any Error>) -> Void) {
        db.collection(collection).document(documentId).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data() else {
                completion(.failure(NSError(domain: "FirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            
            completion(.success(data))
        }
    }
    
    // MARK: - Feedback Methods
    
    func submitFeedback(noteId: String, feedbackText: String, providerName: String, completion: @escaping (Bool, String?) -> Void) {
        db.collection("case_notes").document(noteId).updateData([
            "feedbackText": feedbackText,
            "feedbackProviderName": providerName,
            "isFeedbackRequested": false
        ]) { error in
            completion(error == nil, error?.localizedDescription)
        }
    }
}
