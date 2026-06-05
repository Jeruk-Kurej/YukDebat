//
//  MotionArchiveViewModel.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 29/05/26.
//

// MARK: - MotionArchive - ViewModel

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

/// Manages fetching random motions and synchronizing case notes via external AI proxies.
class MotionArchiveViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var motionsList: [MotionModel] = []
    @Published var myNotes: [CaseBuildingNoteModel] = []
    @Published var communityNotes: [CaseBuildingNoteModel] = []
    @Published var isGenerating: Bool = false

    // UI state yang diakses langsung oleh view
    @Published var searchText: String = ""
    @Published var isHighDemandToastVisible: Bool = false
    @Published var toastMessage: String = ""

    // MARK: - Computed Properties

    var filteredMotions: [MotionModel] {
        if searchText.isEmpty { return motionsList }
        return motionsList.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Dependencies

    private let aiService: GeminiServiceProtocol
    private let localCache: CoreDataStorageServiceProtocol
    private let db = Firestore.firestore()

    private var myNotesListener: ListenerRegistration?
    private var communityNotesListener: ListenerRegistration?

    // MARK: - Initialization

    init(aiService: GeminiServiceProtocol, localCache: CoreDataStorageServiceProtocol)
    {
        self.aiService = aiService
        self.localCache = localCache
        loadDefaultMotions()
    }

    deinit {
        myNotesListener?.remove()
        communityNotesListener?.remove()
    }

    // MARK: - Methods

    /// Fetches a new AI-generated motion and handles potential server limit errors.
    func triggerFetchMotion() {
        guard !isGenerating else { return }

        isGenerating = true
        isHighDemandToastVisible = false

        Task {
            do {
                let motionText = try await aiService.generateMotion()

                let newMotion = MotionModel(
                    id: UUID().uuidString,
                    title: motionText,
                    isWishlisted: false
                )

                await MainActor.run {
                    self.motionsList.insert(newMotion, at: 0)
                    self.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    self.isGenerating = false
                    
                    // Fallback using dummy data
                    let fallbackText = self.dummyMotions.randomElement() ?? "Dewan ini akan mendukung transisi energi hijau secara penuh"
                    let fallbackMotion = MotionModel(
                        id: UUID().uuidString,
                        title: fallbackText,
                        isWishlisted: false
                    )
                    self.motionsList.insert(fallbackMotion, at: 0)
                    
                    // Call error handler to show toast
                    self.handleFetchError(error)
                }
            }
        }
    }

    /// Creates a new note based on a selected debate motion.
    func createNoteFromMotion(_ motion: MotionModel) {
        guard !myNotes.contains(where: { $0.motionTitle == motion.title })
        else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }

        if let idx = motionsList.firstIndex(where: { $0.id == motion.id }) {
            motionsList[idx].isWishlisted = true
        }

        let newNote = CaseBuildingNoteModel(
            id: UUID().uuidString,
            ownerId: userId,
            motionTitle: motion.title,
            argumentsRichText: "",
            visibility: .privateAccess,
            isFeedbackRequested: false,
            updatedAt: Date()
        )
        saveNote(newNote)
    }

    /// Persists a case note to Firestore.
    func saveNote(_ note: CaseBuildingNoteModel) {
        var noteToSave = note
        if noteToSave.ownerId == "user_me" || noteToSave.ownerId.isEmpty {
            noteToSave.ownerId = Auth.auth().currentUser?.uid ?? "unknown"
        }

        var data: [String: Any] = [
            "id": noteToSave.id,
            "ownerId": noteToSave.ownerId,
            "motionTitle": noteToSave.motionTitle,
            "argumentsRichText": noteToSave.argumentsRichText,
            "visibility": noteToSave.visibility.rawValue,
            "isFeedbackRequested": noteToSave.isFeedbackRequested,
            "updatedAt": Timestamp(date: noteToSave.updatedAt),
        ]

        if let feedback = noteToSave.feedbackText {
            data["feedbackText"] = feedback
        }
        if let provider = noteToSave.feedbackProviderName {
            data["feedbackProviderName"] = provider
        }

        db.collection("case_notes").document(noteToSave.id).setData(
            data,
            merge: true
        )
    }

    /// Requests adjudicator feedback for a public note.
    func requestFeedback(for noteId: String) {
        db.collection("case_notes").document(noteId).updateData([
            "isFeedbackRequested": true
        ])
    }

    /// Removes a note from Firestore.
    func deleteNoteFromFirestore(noteId: String) {
        db.collection("case_notes").document(noteId).delete()
    }

    /// Fetches all notes owned by the user.
    func fetchMyNotes(userId: String) {
        myNotesListener?.remove()
        myNotesListener = db.collection("case_notes")
            .whereField("ownerId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                self?.myNotes = self?.mapDocumentsToNotes(documents) ?? []
            }
    }

    /// Fetches all public notes for community viewing.
    func fetchCommunityNotes() {
        communityNotesListener?.remove()
        communityNotesListener = db.collection("case_notes")
            .whereField("visibility", isEqualTo: "PUBLIC")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                self?.communityNotes =
                    self?.mapDocumentsToNotes(documents) ?? []
            }
    }

    // MARK: - Private Helpers

    private func handleFetchError(_ error: Error) {
        let errStr = error.localizedDescription.lowercased()
        if errStr.contains("503") || errStr.contains("demand")
            || errStr.contains("unavailable")
        {
            self.toastMessage = "Server penuh. Menampilkan mosi cadangan."
        } else {
            self.toastMessage = "Gagal memproses AI mosi. Menampilkan mosi cadangan."
        }
        self.isHighDemandToastVisible = true
    }

    private let dummyMotions: [String] = [
        "Kita harus menghentikan segala bentuk eksplorasi ruang angkasa sebelum seluruh masalah kemiskinan di Bumi terselesaikan.",
        "Pemerintah perlu mewajibkan setiap warga negara untuk mengikuti program pelatihan literasi digital selama satu tahun penuh setelah lulus SMA.",
        "Kepemilikan hak cipta atas karya seni yang dihasilkan oleh AI seharusnya tidak diberikan kepada siapa pun (menjadi milik publik).",
        "Penyelenggaraan konser musik skala besar harus dilarang demi menekan jejak karbon yang dihasilkan oleh mobilitas penonton.",
        "Kehidupan di kota besar sebaiknya tidak lagi diukur berdasarkan pendapatan ekonomi, melainkan berdasarkan skor aksesibilitas ruang terbuka hijau.",
        "Setiap individu harus memiliki batas maksimal penggunaan data internet per bulan demi keberlangsungan ekosistem server global.",
        "Kita sebaiknya mewajibkan setiap politisi untuk menjalani tes psikologi independen secara berkala di depan publik.",
        "Warisan kekayaan pribadi di atas 10 miliar rupiah harus disita oleh negara secara otomatis untuk dana pendidikan nasional.",
        "Hubungan romantis di tempat kerja seharusnya dilarang keras demi menjaga profesionalisme dan produktivitas organisasi.",
        "Perusahaan rintisan (startup) tidak boleh lagi mendapatkan pendanaan dari investor asing guna menjaga kedaulatan data ekonomi dalam negeri.",
        "Dewan ini akan melarang produksi dan konsumsi daging hewan untuk menyelamatkan lingkungan hidup.",
        "Dewan ini percaya bahwa pendidikan universitas harus digratiskan sepenuhnya oleh negara.",
        "Dewan ini akan menghapus tes standar nasional sebagai syarat kelulusan dan penerimaan di institusi pendidikan.",
        "Dewan ini akan memungut pajak yang tinggi untuk industri fast fashion demi mengurangi limbah.",
        "Dewan ini percaya bahwa media sosial lebih banyak memberikan dampak negatif daripada positif bagi perkembangan remaja.",
        "Dewan ini akan mewajibkan pemilu diselenggarakan secara elektronik (e-voting) untuk meningkatkan partisipasi masyarakat.",
        "Dewan ini percaya bahwa orang tua harus bertanggung jawab secara pidana atas tindak kejahatan yang dilakukan oleh anak di bawah umur.",
        "Dewan ini akan menghukum negara-negara maju yang tidak mau menerima pengungsi akibat krisis iklim.",
        "Dewan ini percaya bahwa kecerdasan buatan (AI) akan membawa dampak buruk bagi stabilitas lapangan kerja global.",
        "Dewan ini akan memberikan subsidi penuh bagi industri lokal untuk bersaing dengan perusahaan multinasional."
    ]

    private func mapDocumentsToNotes(_ documents: [QueryDocumentSnapshot])
        -> [CaseBuildingNoteModel]
    {
        return documents.compactMap { doc -> CaseBuildingNoteModel? in
            let data = doc.data()
            let visibilityStr = data["visibility"] as? String ?? "PRIVATE"

            return CaseBuildingNoteModel(
                id: doc.documentID,
                ownerId: data["ownerId"] as? String ?? "",
                motionTitle: data["motionTitle"] as? String ?? "",
                argumentsRichText: data["argumentsRichText"] as? String ?? "",
                visibility: (visibilityStr == "PUBLIC"
                    || visibilityStr == "public")
                    ? .publicAccess : .privateAccess,
                isFeedbackRequested: data["isFeedbackRequested"] as? Bool
                    ?? false,
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
                    ?? Date(),
                feedbackText: data["feedbackText"] as? String,
                feedbackProviderName: data["feedbackProviderName"] as? String
            )
        }.sorted { $0.updatedAt > $1.updatedAt }
    }

    private func loadDefaultMotions() {
        motionsList = [
            MotionModel(
                id: "m1",
                title: "Melarang penggunaan AI di institusi pendidikan formal.",
                isWishlisted: false
            ),
            MotionModel(
                id: "m2",
                title: "Menyesali glorifikasi budaya kerja berlebihan.",
                isWishlisted: false
            ),
        ]
    }
}
