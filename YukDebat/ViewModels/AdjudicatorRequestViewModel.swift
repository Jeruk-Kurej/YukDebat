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

class AdjudicatorRequestViewModel: ObservableObject {
    
    @Published var experience: String = ""
    @Published var selectedImageData: Data? = nil
    
    @Published var hasPendingRequest: Bool = false
    @Published var isLoading: Bool = false
    @Published var statusMsg: String? = nil
    
    private let db = Firestore.firestore()
    private let storageService: CloudStorageProtocol = CloudinaryService() // Injeksi Cloudinary
    
    func checkExistingRequest() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("adjudicator_requests").whereField("userId", isEqualTo: userId).whereField("status", isEqualTo: "PENDING").getDocuments { snapshot, _ in
            if let docs = snapshot?.documents, !docs.isEmpty { DispatchQueue.main.async { self.hasPendingRequest = true } }
        }
    }
    
    func submitRequest(userName: String, userEmail: String) {
        guard let userId = Auth.auth().currentUser?.uid, let imageData = selectedImageData else { return }
        
        isLoading = true
        
        Task {
            do {
                // 1. Upload ke Cloudinary
                let uploadedUrl = try await storageService.uploadImage(imageData: imageData)
                
                // 2. Simpan URL ke Firestore
                let reqId = UUID().uuidString
                let data: [String: Any] = [
                    "id": reqId, "userId": userId, "userEmail": userEmail,
                    "fullName": userName, "experience": experience,
                    "certificateUrl": uploadedUrl,
                    "status": ReviewStatus.pending.rawValue,
                    "submittedAt": Timestamp(date: Date())
                ]
                
                try await db.collection("adjudicator_requests").document(reqId).setData(data)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.statusMsg = "Request successfully submitted!"
                    self.hasPendingRequest = true
                    self.experience = ""; self.selectedImageData = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.statusMsg = "Failed to submit: \(error.localizedDescription)"
                }
            }
        }
    }
}
