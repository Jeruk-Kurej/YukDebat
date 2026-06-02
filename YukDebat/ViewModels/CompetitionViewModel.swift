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

class CompetitionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var activeCompetitions: [CompetitionModel] = []
    @Published var myPendingCompetitions: [CompetitionModel] = []

    @Published var name: String = ""
    @Published var desc: String = ""
    @Published var eventDate: Date = Date()
    @Published var registrationUrl: String = ""
    @Published var selectedImageData: Data? = nil

    @Published var isLoading: Bool = false
    @Published var statusMessage: String? = nil

    var hasError: Bool { return statusMessage?.contains("Failed") ?? false }

    private let db = Firestore.firestore()
    private let storageService: CloudStorageProtocol = CloudinaryService()

    func fetchCompetitions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("competitions").addSnapshotListener {
            [weak self] snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            var active: [CompetitionModel] = []
            var pending: [CompetitionModel] = []
            for doc in docs {
                let data = doc.data()
                let status =
                    ReviewStatus(
                        rawValue: data["status"] as? String ?? "PENDING"
                    ) ?? .pending
                let promoterId = data["promoterId"] as? String ?? ""
                let model = CompetitionModel(
                    id: doc.documentID,
                    promoterId: promoterId,
                    promoterEmail: data["promoterEmail"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    eventDate: (data["eventDate"] as? Timestamp)?.dateValue()
                        ?? Date(),
                    registrationUrl: data["registrationUrl"] as? String ?? "",
                    posterStorageUrl: data["posterUrl"] as? String ?? "",
                    status: status
                )
                if status == .active {
                    active.append(model)
                } else if status == .pending && promoterId == userId {
                    pending.append(model)
                }
            }
            DispatchQueue.main.async {
                self?.activeCompetitions = active
                self?.myPendingCompetitions = pending
            }
        }
    }

    func submitCompetitionData() {
        guard let userId = Auth.auth().currentUser?.uid,
            let userEmail = Auth.auth().currentUser?.email,
            let imageData = selectedImageData
        else { return }

        let calendar = Calendar.current
        if calendar.compare(eventDate, to: Date(), toGranularity: .day)
            == .orderedAscending
        {
            self.statusMessage =
                "Error: Tanggal kompetisi tidak boleh di masa lalu."
            return
        }
        // ----------------------------------

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

                db.collection("competitions").document(compId).setData(data) {
                    [weak self] error in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if let error = error {
                            self?.statusMessage =
                                "Failed to submit: \(error.localizedDescription)"
                        } else {
                            self?.statusMessage = "Competition submitted!"
                            self?.name = ""
                            self?.desc = ""
                            self?.selectedImageData = nil
                            self?.registrationUrl = ""
                            self?.eventDate = Date()
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.statusMessage =
                        "Failed to submit: \(error.localizedDescription)"
                }
            }
        }
    }
}
