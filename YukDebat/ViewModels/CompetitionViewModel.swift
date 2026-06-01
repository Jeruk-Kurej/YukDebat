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
    
    // MARK: - Published Properties (UI State)
    
    @Published var activeCompetitions: [CompetitionModel] = []
    @Published var myPendingCompetitions: [CompetitionModel] = []
    
    // Form Properties
    @Published var name: String = ""
    @Published var desc: String = ""
    @Published var selectedImageData: Data? = nil
    
    // Status Properties
    @Published var isLoading: Bool = false
    @Published var statusMessage: String? = nil
    
    // MARK: - Computed Properties
    
    /// Menentukan apakah Toast harus berwarna merah (Error) atau hijau (Success)
    var hasError: Bool {
        return statusMessage?.contains("Failed") ?? false
    }
    
    // MARK: - Private Properties
    
    private let db = Firestore.firestore()
    
    // MARK: - Methods
    
    func fetchCompetitions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("competitions").addSnapshotListener { [weak self] snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            
            var active: [CompetitionModel] = []
            var pending: [CompetitionModel] = []
            
            for doc in docs {
                let data = doc.data()
                let statusStr = data["status"] as? String ?? "PENDING"
                let status = ReviewStatus(rawValue: statusStr) ?? .pending
                let promoterId = data["promoterId"] as? String ?? ""
                
                let model = CompetitionModel(
                    id: doc.documentID,
                    promoterId: promoterId,
                    promoterEmail: data["promoterEmail"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    eventDate: (data["eventDate"] as? Timestamp)?.dateValue() ?? Date(),
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
              let userEmail = Auth.auth().currentUser?.email else { return }
        
        isLoading = true
        let compId = UUID().uuidString
        
        // Menggunakan kompresi Base64 sebagai workaround sementara Firebase Storage
        let base64Image = selectedImageData?.base64EncodedString() ?? ""
        
        let data: [String: Any] = [
            "id": compId,
            "promoterId": userId,
            "promoterEmail": userEmail,
            "name": name,
            "description": desc,
            "eventDate": Timestamp(date: Date().addingTimeInterval(86400 * 30)),
            "registrationUrl": "",
            "posterUrl": base64Image,
            "status": ReviewStatus.pending.rawValue
        ]
        
        db.collection("competitions").document(compId).setData(data) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.statusMessage = "Failed to submit: \(error.localizedDescription)"
                } else {
                    self?.statusMessage = "Competition submitted for Admin review!"
                    // Kosongkan form setelah sukses
                    self?.name = ""
                    self?.desc = ""
                    self?.selectedImageData = nil
                }
            }
        }
    }
}
