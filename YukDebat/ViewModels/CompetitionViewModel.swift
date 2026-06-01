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

/// Manages the fetching of competitions and handles promoter submissions.
class CompetitionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var activeCompetitions: [CompetitionModel] = []
    @Published var myPendingCompetitions: [CompetitionModel] = []
    
    @Published var name: String = ""
    @Published var desc: String = ""
    @Published var selectedImageData: Data? = nil
    
    @Published var isLoading: Bool = false
    @Published var statusMessage: String? = nil
    
    var hasError: Bool { return statusMessage?.contains("Failed") ?? false }
    
    // MARK: - Private Properties
    private let db = Firestore.firestore()
    private let storageService: CloudStorageProtocol = CloudinaryService() // Injeksi Dependency Cloudinary
    
    // MARK: - Methods
    
    func fetchCompetitions() {
        // Logika Fetch tetap sama (jangan diubah)
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("competitions").addSnapshotListener { [weak self] snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            var active: [CompetitionModel] = []
            var pending: [CompetitionModel] = []
            for doc in docs {
                let data = doc.data()
                let status = ReviewStatus(rawValue: data["status"] as? String ?? "PENDING") ?? .pending
                let promoterId = data["promoterId"] as? String ?? ""
                let model = CompetitionModel(
                    id: doc.documentID, promoterId: promoterId, promoterEmail: data["promoterEmail"] as? String ?? "",
                    name: data["name"] as? String ?? "", description: data["description"] as? String ?? "",
                    eventDate: (data["eventDate"] as? Timestamp)?.dateValue() ?? Date(),
                    registrationUrl: data["registrationUrl"] as? String ?? "", posterStorageUrl: data["posterUrl"] as? String ?? "",
                    status: status
                )
                if status == .active { active.append(model) } else if status == .pending && promoterId == userId { pending.append(model) }
            }
            DispatchQueue.main.async { self?.activeCompetitions = active; self?.myPendingCompetitions = pending }
        }
    }
    
    func submitCompetitionData() {
        guard let userId = Auth.auth().currentUser?.uid, let userEmail = Auth.auth().currentUser?.email, let imageData = selectedImageData else { return }
        
        isLoading = true
        
        Task {
            do {
                // 1. Upload ke Cloudinary dan dapatkan secure_url HTTP
                let uploadedUrl = try await storageService.uploadImage(imageData: imageData)
                
                // 2. Simpan URL ke Firestore
                let compId = UUID().uuidString
                let data: [String: Any] = [
                    "id": compId, "promoterId": userId, "promoterEmail": userEmail,
                    "name": name, "description": desc,
                    "eventDate": Timestamp(date: Date().addingTimeInterval(86400 * 30)),
                    "registrationUrl": "", "posterUrl": uploadedUrl,
                    "status": ReviewStatus.pending.rawValue
                ]
                
                try await db.collection("competitions").document(compId).setData(data)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.statusMessage = "Competition submitted for Admin review!"
                    self.name = ""; self.desc = ""; self.selectedImageData = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.statusMessage = "Failed to submit: \(error.localizedDescription)"
                }
            }
        }
    }
}
