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
            self.toastMessage = "Server Gemini sedang penuh. Coba lagi nanti!"
        } else {
            self.toastMessage = "Gagal memproses AI mosi."
        }
        self.isHighDemandToastVisible = true
    }

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
