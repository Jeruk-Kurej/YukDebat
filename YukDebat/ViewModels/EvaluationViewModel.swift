//
//  EvaluationViewModel.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Combine
import Foundation

class EvaluationViewModel: ObservableObject {

    @Published var errorMessage: String? = nil
    @Published var isSubmissionSuccessful: Bool = false

    private let dbService: FirestoreServiceProtocol

    init(dbService: FirestoreServiceProtocol) {
        self.dbService = dbService
    }

    func submitScore(evaluationId: String, score: Int, feedback: String) {
        guard score >= 50 && score <= 100 else {
            self.errorMessage =
                "Ditolak: Skor debat format BP harus berada di rentang 50 hingga 100."
            return
        }

        Task {
            do {
                let data: [String: Any] = [
                    "score": score, "feedback": feedback,
                ]
                try await dbService.saveDocument(
                    collection: "evaluations",
                    documentId: evaluationId,
                    data: data
                )

                DispatchQueue.main.async {
                    self.isSubmissionSuccessful = true
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage =
                        "Gagal mengirim evaluasi: \(error.localizedDescription)"
                }
            }
        }
    }
}
