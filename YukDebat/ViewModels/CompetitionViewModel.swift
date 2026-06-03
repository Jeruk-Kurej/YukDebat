//
//  CompetitionViewModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 29/05/26.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

/// Manages competition listing, submission, and status tracking for organizers.
@MainActor
class CompetitionViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var activeCompetitions: [CompetitionModel] = []
    @Published var myPendingCompetitions: [CompetitionModel] = []

    @Published var name: String = ""
    @Published var desc: String = ""
    @Published var eventDate: Date = Date()
    @Published var registrationUrl: String = ""
    @Published var selectedImageData: Data? = nil

    @Published private(set) var isLoading: Bool = false
    @Published var statusMessage: String? = nil

    var hasError: Bool {
        return statusMessage?.contains("Failed") ?? false
    }

    // MARK: - Properties

    private let db = Firestore.firestore()
    private let storageService: CloudStorageProtocol

    // MARK: - Initialization

    /// Initializes with required dependencies.
    /// - Parameter storageService: Protocol implementation for cloud storage.
    init(storageService: CloudStorageProtocol) {
        self.storageService = storageService
    }

    // MARK: - Methods

    /// Fetches all competitions and separates them into active and pending lists.
    func fetchCompetitions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("competitions").addSnapshotListener {
            [weak self] snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            var active: [CompetitionModel] = []
            var pending: [CompetitionModel] = []

            for doc in docs {
                let data = doc.data()
                let model = self?.mapToCompetition(doc: doc)

                guard let model = model else { continue }

                if model.status == .active {
                    active.append(model)
                } else if model.status == .pending && model.promoterId == userId
                {
                    pending.append(model)
                }
            }

            self?.activeCompetitions = active
            self?.myPendingCompetitions = pending
        }
    }

    /// Submits competition data to Firestore after uploading the poster image.
    func submitCompetitionData() {
        guard let userId = Auth.auth().currentUser?.uid,
            let userEmail = Auth.auth().currentUser?.email,
            let imageData = selectedImageData
        else { return }

        isLoading = true

        Task {
            do {
                let uploadedUrl = try await storageService.uploadImage(
                    imageData: imageData
                )
                let compId = UUID().uuidString

                let data: [String: Any] = [
                    "id": compId,
                    "promoterId": userId,
                    "promoterEmail": userEmail,
                    "name": name,
                    "description": desc,
                    "eventDate": Timestamp(date: self.eventDate),
                    "registrationUrl": self.registrationUrl,
                    "posterUrl": uploadedUrl,
                    "status": ReviewStatus.pending.rawValue,
                ]

                try await db.collection("competitions").document(compId)
                    .setData(data)

                self.statusMessage = "Competition submitted!"
                self.clearForm()
            } catch {
                self.statusMessage =
                    "Failed to submit: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }

    // MARK: - Private Helpers

    /// Clears form fields after successful submission.
    private func clearForm() {
        self.name = ""
        self.desc = ""
        self.selectedImageData = nil
        self.registrationUrl = ""
        self.eventDate = Date()
    }

    /// Maps Firestore document to CompetitionModel.
    private func mapToCompetition(doc: QueryDocumentSnapshot)
        -> CompetitionModel
    {
        let data = doc.data()
        let statusRaw = data["status"] as? String ?? "PENDING"

        return CompetitionModel(
            id: doc.documentID,
            promoterId: data["promoterId"] as? String ?? "",
            promoterEmail: data["promoterEmail"] as? String ?? "",
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            eventDate: (data["eventDate"] as? Timestamp)?.dateValue() ?? Date(),
            registrationUrl: data["registrationUrl"] as? String ?? "",
            posterStorageUrl: data["posterUrl"] as? String ?? "",
            status: ReviewStatus(rawValue: statusRaw) ?? .pending
        )
    }
}
