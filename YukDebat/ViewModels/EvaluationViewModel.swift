import Combine
import FirebaseFirestore
import Foundation

@MainActor
class EvaluationViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var pendingRequests: [CaseBuildingNoteModel] = []
    @Published var historyRequests: [CaseBuildingNoteModel] = []
    @Published var statusMessage: String?
    @Published var hasError: Bool = false

    // MARK: - Properties
    let dbService: FirestoreServiceProtocol
    private let db = Firestore.firestore()
    private var pendingListener: ListenerRegistration?
    private var historyListener: ListenerRegistration?

    // MARK: - Initialization
    init(dbService: FirestoreServiceProtocol) {
        self.dbService = dbService
    }

    // MARK: - Methods

    /// Fungsi utama untuk mengambil data terbaru (panggil ini setelah submit)
    func fetchEvaluations() {
        fetchPendingFeedbacks()
    }

    func fetchPendingFeedbacks() {
        pendingListener?.remove()
        pendingListener = db.collection("case_notes")
            .whereField("isFeedbackRequested", isEqualTo: true)
            .whereField("visibility", isEqualTo: "PUBLIC")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let docs = snapshot?.documents else { return }

                let notes = docs.compactMap { doc -> CaseBuildingNoteModel? in
                    let data = doc.data()
                    if data["feedbackText"] != nil { return nil }
                    return self?.mapToNote(from: doc)
                }

                self?.pendingRequests = notes.sorted {
                    $0.updatedAt < $1.updatedAt
                }
            }
    }

    func fetchEvaluationHistory(providerName: String) {
        historyListener?.remove()
        historyListener = db.collection("case_notes")
            .whereField("feedbackProviderName", isEqualTo: providerName)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let docs = snapshot?.documents else { return }

                let notes = docs.compactMap { self?.mapToNote(from: $0) }
                self?.historyRequests = notes.sorted {
                    $0.updatedAt > $1.updatedAt
                }
            }
    }

    func submitFeedback(
        noteId: String,
        feedbackText: String,
        providerName: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        self.dbService.submitFeedback(
            noteId: noteId,
            feedbackText: feedbackText,
            providerName: providerName
        ) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.statusMessage = "Feedback berhasil dikirim!"
                    // Optimistic UI update to ensure instant reflection without waiting for listener
                    if let self = self, let index = self.pendingRequests.firstIndex(where: { $0.id == noteId }) {
                        var updatedNote = self.pendingRequests[index]
                        updatedNote.feedbackText = feedbackText
                        updatedNote.feedbackProviderName = providerName
                        updatedNote.isFeedbackRequested = false
                        
                        self.pendingRequests.remove(at: index)
                        self.historyRequests.insert(updatedNote, at: 0)
                        self.historyRequests.sort { $0.updatedAt > $1.updatedAt }
                    }
                } else {
                    self?.statusMessage = "Error: \(error ?? "Gagal submit")"
                }
                completion(success, error)
            }
        }
    }

    // MARK: - Private Helpers
    private func mapToNote(from doc: QueryDocumentSnapshot)
        -> CaseBuildingNoteModel
    {
        let data = doc.data()
        return CaseBuildingNoteModel(
            id: doc.documentID,
            ownerId: data["ownerId"] as? String ?? "",
            motionTitle: data["motionTitle"] as? String ?? "",
            argumentsRichText: data["argumentsRichText"] as? String ?? "",
            visibility: .publicAccess,
            isFeedbackRequested: data["isFeedbackRequested"] as? Bool ?? false,
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
            feedbackText: data["feedbackText"] as? String,
            feedbackProviderName: data["feedbackProviderName"] as? String
        )
    }
}
