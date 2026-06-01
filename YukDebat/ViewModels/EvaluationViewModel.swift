//
//  EvaluationViewModel.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Combine
import FirebaseFirestore
import Foundation

/// Manages the feedback loop between Adjudicators and Debaters for Case Building Notes.
class EvaluationViewModel: ObservableObject {

    // MARK: - Published Properties
    
    @Published var pendingRequests: [CaseBuildingNoteModel] = []
    @Published var historyRequests: [CaseBuildingNoteModel] = []

    // MARK: - Methods

    func fetchPendingFeedbacks() {
        let db = Firestore.firestore()
        db.collection("case_notes")
            .whereField("isFeedbackRequested", isEqualTo: true)
            .whereField("visibility", isEqualTo: "PUBLIC")
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                
                self.pendingRequests = docs.compactMap { doc in
                    let data = doc.data()
                    // Jika sudah ada feedbackText, berarti sudah direview, jangan tampilkan di pending
                    if data["feedbackText"] != nil { return nil }
                    
                    return CaseBuildingNoteModel(
                        id: doc.documentID,
                        ownerId: data["ownerId"] as? String ?? "",
                        motionTitle: data["motionTitle"] as? String ?? "",
                        argumentsRichText: data["argumentsRichText"] as? String ?? "",
                        visibility: .publicAccess,
                        isFeedbackRequested: true,
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                        feedbackText: data["feedbackText"] as? String,
                        feedbackProviderName: data["feedbackProviderName"] as? String
                    )
                }
                self.pendingRequests.sort { $0.updatedAt < $1.updatedAt }
            }
    }

    func fetchEvaluationHistory(providerName: String) {
        let db = Firestore.firestore()
        db.collection("case_notes")
            .whereField("feedbackProviderName", isEqualTo: providerName)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                
                self.historyRequests = docs.compactMap { doc in
                    let data = doc.data()
                    return CaseBuildingNoteModel(
                        id: doc.documentID,
                        ownerId: data["ownerId"] as? String ?? "",
                        motionTitle: data["motionTitle"] as? String ?? "",
                        argumentsRichText: data["argumentsRichText"] as? String ?? "",
                        visibility: .publicAccess,
                        isFeedbackRequested: data["isFeedbackRequested"] as? Bool ?? false,
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                        feedbackText: data["feedbackText"] as? String,
                        feedbackProviderName: data["feedbackProviderName"] as? String
                    )
                }
                self.historyRequests.sort { $0.updatedAt > $1.updatedAt }
            }
    }

    func submitFeedback(noteId: String, feedbackText: String, providerName: String) {
        let db = Firestore.firestore()
        db.collection("case_notes").document(noteId).updateData([
            "feedbackText": feedbackText,
            "feedbackProviderName": providerName,
            "isFeedbackRequested": false,
        ])
    }
}
