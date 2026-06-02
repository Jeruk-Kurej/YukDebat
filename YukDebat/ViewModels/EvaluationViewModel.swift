//
//  EvaluationViewModel.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi 29/05/26
//

import Combine
import FirebaseFirestore
import Foundation

/// Manages the feedback loop between Adjudicators and Debaters for Case Building Notes.
@MainActor
class EvaluationViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var pendingRequests: [CaseBuildingNoteModel] = []
    @Published var historyRequests: [CaseBuildingNoteModel] = []

    // MARK: - Properties

    private let db = Firestore.firestore()

    // MARK: - Methods

    /// Fetches all public notes that are requesting feedback but have not received it yet.
    func fetchPendingFeedbacks() {
        db.collection("case_notes")
            .whereField("isFeedbackRequested", isEqualTo: true)
            .whereField("visibility", isEqualTo: "PUBLIC")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let docs = snapshot?.documents else { return }

                let notes = docs.compactMap { doc -> CaseBuildingNoteModel? in
                    let data = doc.data()
                    // Filter: Only include notes without feedback text
                    if data["feedbackText"] != nil { return nil }
                    return self?.mapToNote(from: doc)
                }

                self?.pendingRequests = notes.sorted {
                    $0.updatedAt < $1.updatedAt
                }
            }
    }

    /// Fetches evaluation history for a specific adjudicator.
    /// - Parameter providerName: The name of the adjudicator.
    func fetchEvaluationHistory(providerName: String) {
        db.collection("case_notes")
            .whereField("feedbackProviderName", isEqualTo: providerName)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let docs = snapshot?.documents else { return }

                let notes = docs.compactMap { self?.mapToNote(from: $0) }
                self?.historyRequests = notes.sorted {
                    $0.updatedAt > $1.updatedAt
                }
            }
    }

    /// Submits feedback to Firestore and updates the request status.
    /// - Parameters:
    ///   - noteId: The unique identifier of the note.
    ///   - feedbackText: The feedback content.
    ///   - providerName: The name of the adjudicator.
    ///   - completion: Callback returning success status and optional error message.
    func submitFeedback(
        noteId: String,
        feedbackText: String,
        providerName: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        db.collection("case_notes").document(noteId).updateData([
            "feedbackText": feedbackText,
            "feedbackProviderName": providerName,
            "isFeedbackRequested": false,
        ]) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }

    // MARK: - Private Helpers

    /// Maps Firestore document data to a CaseBuildingNoteModel.
    private func mapToNote(from doc: QueryDocumentSnapshot)
        -> CaseBuildingNoteModel
    {
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
}
