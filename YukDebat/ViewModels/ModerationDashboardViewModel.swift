//
//  ModerationDashboardViewModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 29/05/26.
//

import Combine
import Foundation

class ModerationDashboardViewModel: ObservableObject {

    @Published var pendingCompetitions: [CompetitionModel] = []
    @Published var errorMessage: String? = nil
    @Published var actionSuccessMessage: String? = nil

    private let dbService: FirestoreServiceProtocol
    private let storageService: CloudStorageProtocol

    init(
        dbService: FirestoreServiceProtocol,
        storageService: CloudStorageProtocol
    ) {
        self.dbService = dbService
        self.storageService = storageService
    }

    // Fungsi ini wajib ada karena dipanggil di ModerationDashboardView
    func fetchPendingData() {
        // Logika untuk mengambil data kompetisi berstatus pending
        print("Fetching pending data...")
    }

    // Fungsi ini wajib ada karena dipanggil di ModerationDashboardView
    func approveContent(docId: String) {
        Task {
            do {
                try await dbService.updateTransactional(
                    collection: "competitions",
                    documentId: docId,
                    data: ["status": ReviewStatus.active.rawValue]
                )
                DispatchQueue.main.async {
                    self.actionSuccessMessage = "Kompetisi berhasil disetujui."
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage =
                        "Gagal menyetujui: \(error.localizedDescription)"
                }
            }
        }
    }
}
