//
//  AdjudicatorRequestViewModel.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 01-06-2026.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

/// Manages the submission and status tracking of adjudicator certification requests.
@MainActor
class AdjudicatorRequestViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var experience: String = ""
    @Published var selectedImageData: Data? = nil

    @Published var hasPendingRequest: Bool = false
    @Published var isLoading: Bool = false
    @Published var statusMessage: String? = nil

    // MARK: - Properties

    private let db = Firestore.firestore()
    private let storageService: CloudStorageServiceProtocol

    // MARK: - Initialization

    /// Initializes with dependency injection for storage services.
    /// - Parameter storageService: Protocol implementation for cloud storage.
    init(storageService: CloudStorageServiceProtocol) {
        self.storageService = storageService
    }

    // MARK: - Methods

    /// Checks if the user already has an ongoing request to become an adjudicator.
    func checkExistingRequest() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("adjudicator_requests")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "PENDING")
            .getDocuments { [weak self] snapshot, _ in
                let exists = snapshot?.documents.isEmpty == false
                DispatchQueue.main.async {
                    self?.hasPendingRequest = exists
                }
            }
    }

    /// Submits the adjudicator request, including image upload and Firestore record creation.
    /// - Parameters:
    ///   - userName: The full name of the user.
    ///   - userEmail: The email address of the user.
    func submitRequest(userName: String, userEmail: String) {
        guard let userId = Auth.auth().currentUser?.uid,
            let imageData = selectedImageData
        else { return }

        isLoading = true
        statusMessage = nil

        Task {
            do {
                // 1. Upload certificate image to Cloud Storage
                let uploadedUrl = try await storageService.uploadImage(
                    imageData: imageData
                )

                // 2. Save Request Data to Firestore
                let reqId = UUID().uuidString
                let data: [String: Any] = [
                    "id": reqId,
                    "userId": userId,
                    "userEmail": userEmail,
                    "fullName": userName,
                    "experience": experience,
                    "certificateUrl": uploadedUrl,
                    "status": ReviewStatus.pending.rawValue,
                    "submittedAt": Timestamp(date: Date()),
                ]

                try await db.collection("adjudicator_requests").document(reqId)
                    .setData(data)

                // 3. Success State
                self.isLoading = false
                self.statusMessage = "Request successfully submitted!"
                self.hasPendingRequest = true
                self.resetForm()

            } catch {
                self.isLoading = false
                self.statusMessage =
                    "Failed to submit: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Private Helpers

    private func resetForm() {
        self.experience = ""
        self.selectedImageData = nil
    }
}
