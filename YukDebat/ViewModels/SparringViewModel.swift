//
//  SparringViewModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto 29/05/26
//

// MARK: - Sparring - ViewModel

import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

/// Manages sparring room sessions, participant slots, and matching logic.
@MainActor
class SparringViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var lobbyRooms: [SparringRoomModel] = []
    @Published var pendingRequests: [String: [ParticipantModel]] =
        [:]

    @Published var alertMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isShowingCreateRoom: Bool = false

    // Form Inputs
    @Published var formMotionTitle: String = ""
    @Published var formScheduledTime: Date = Date().addingTimeInterval(3600)
    @Published var formMeetingLink: String = ""
    @Published var formSpecialNotes: String = ""
    @Published var isFormPrivate: Bool = false

    // MARK: - Properties

    private let dbService: FirestoreServiceProtocol
    private let db = Firestore.firestore()

    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - Initialization

    init(dbService: FirestoreServiceProtocol) {
        self.dbService = dbService
    }

    // MARK: - Methods

    /// Listens to real-time updates for sparring rooms.
    func listenToRooms() {
        db.collection("sparring_rooms")
            .order(by: "scheduledTime", descending: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let docs = snapshot?.documents else {
                    return
                }
                self.processSnapshot(docs)
            }
    }

    /// Creates a new sparring room.
    func submitRoomForm() {
        self.errorMessage = nil
        self.alertMessage = nil

        guard !formMeetingLink.isEmpty else {
            self.errorMessage = "Meeting Link tidak boleh kosong."
            return
        }

        guard formScheduledTime >= Date().addingTimeInterval(-120) else {
            self.errorMessage = "Waktu sparring tidak boleh di masa lalu."
            return
        }

        guard let userId = Auth.auth().currentUser?.uid else { return }

        let newRoomId = UUID().uuidString
        let roomData: [String: Any] = [
            "id": newRoomId,
            "hostId": userId,
            "scheduledTime": Timestamp(date: self.formScheduledTime),
            "motionTitle": self.formMotionTitle.isEmpty
                ? "Topik Bebas" : self.formMotionTitle,
            "specialNotes": self.formSpecialNotes,
            "meetingLink": self.formMeetingLink,
            "accessType": self.isFormPrivate ? "PRIVATE" : "PUBLIC",
            "state": "PREPARING",
            "participants": [],
            "pendingRequests": [],
            "isAdjudicatorNeeded": true,
        ]

        db.collection("sparring_rooms").document(newRoomId).setData(roomData) {
            error in
            if error == nil {
                self.alertMessage = "Ruang sparring berhasil dibuat!"
                self.isShowingCreateRoom = false
            }
        }
    }

    /// Joins a room directly (for public rooms).
    func joinRoom(room: SparringRoomModel, mode: RegMode) {
        guard let user = Auth.auth().currentUser else { return }
        let userId = user.uid
        let email = user.email ?? ""
        var name = user.displayName ?? email.components(separatedBy: "@").first ?? "Debater"
        if mode == .team { name += " Team" }

        let newParticipant: [String: Any] = [
            "userId": userId,
            "userName": name,
            "userEmail": email,
            "roleSlot": RoleSlotType.openingGovt.rawValue,
            "regMode": mode.rawValue,
        ]

        db.collection("sparring_rooms").document(room.id).updateData([
            "participants": FieldValue.arrayUnion([newParticipant])
        ]) { error in
            if error == nil { self.alertMessage = "Berhasil Join!" }
        }
    }

    /// Requests to join a room (for private/moderated rooms).
    func requestJoin(roomId: String, role: RoleSlotType, isTeam: Bool) {
        guard let user = Auth.auth().currentUser else { return }
        let userId = user.uid
        let email = user.email ?? ""
        var userName = user.displayName ?? email.components(separatedBy: "@").first ?? "Debater"
        if isTeam { userName += " Team" }

        let mode: RegMode = isTeam ? .team : .solo
        let newRequest: [String: Any] = [
            "userId": userId,
            "userName": userName,
            "userEmail": email,
            "roleSlot": role.rawValue,
            "regMode": mode.rawValue,
        ]

        db.collection("sparring_rooms").document(roomId).updateData([
            "pendingRequests": FieldValue.arrayUnion([newRequest])
        ]) { error in
            if error == nil { self.alertMessage = "Permintaan dikirim!" }
        }
    }

    /// Accepts a user request to join.
    func acceptRequest(roomId: String, participantId: String) {
        guard let pendingList = pendingRequests[roomId],
            let acceptedUser = pendingList.first(where: {
                $0.userId == participantId
            })
        else { return }

        let participantDict = acceptedUser.toDictionary()

        let updatedPending = pendingList.filter { $0.userId != participantId }
            .map { $0.toDictionary() }

        db.collection("sparring_rooms").document(roomId).updateData([
            "participants": FieldValue.arrayUnion([participantDict]),
            "pendingRequests": updatedPending,
        ])
    }

    /// Rejects a user request.
    func rejectRequest(roomId: String, participantId: String) {
        guard let pendingList = pendingRequests[roomId] else { return }
        let updatedPending = pendingList.filter { $0.userId != participantId }
            .map { $0.toDictionary() }

        db.collection("sparring_rooms").document(roomId).updateData([
            "pendingRequests": updatedPending
        ])
    }

    /// Cancels user's own join request.
    func cancelRequest(roomId: String) {
        guard let userId = Auth.auth().currentUser?.uid,
            let pendingList = pendingRequests[roomId]
        else { return }

        let updatedPending = pendingList.filter { $0.userId != userId }.map {
            $0.toDictionary()
        }

        db.collection("sparring_rooms").document(roomId).updateData([
            "pendingRequests": updatedPending
        ])
    }

    /// Removes user from room.
    func leaveRoom(roomId: String) {
        guard let userId = Auth.auth().currentUser?.uid,
            let room = lobbyRooms.first(where: { $0.id == roomId })
        else { return }

        let updatedParticipants = room.participants.filter {
            $0.userId != userId
        }.map { $0.toDictionary() }

        db.collection("sparring_rooms").document(roomId).updateData([
            "participants": updatedParticipants
        ])
    }

    /// Removes a specific participant from the room (Host action).
    func removeParticipant(room: SparringRoomModel, userId: String) {
        let updatedParticipants = room.participants
            .filter { $0.userId != userId }
            .map { $0.toDictionary() }

        db.collection("sparring_rooms").document(room.id).updateData([
            "participants": updatedParticipants
        ])
    }

    /// Completes the room session.
    func completeRoom(roomId: String) {
        db.collection("sparring_rooms").document(roomId).updateData([
            "state": "DONE"
        ]) { error in
            if error == nil {
                self.alertMessage = "Ruang sparring telah selesai! 🏁"
            }
        }
    }

    /// Updates room visibility
    func updateVisibility(roomId: String, newVisibility: VisibilityType) {
        db.collection("sparring_rooms").document(roomId).updateData([
            "accessType": newVisibility.rawValue
        ])
    }

    // MARK: - Helpers (Status Checkers)

    func isUserInRoom(room: SparringRoomModel) -> Bool {
        room.participants.contains(where: { $0.userId == currentUserId })
    }

    func isUserHost(room: SparringRoomModel) -> Bool {
        room.hostId == currentUserId
    }

    func isUserPending(room: SparringRoomModel) -> Bool {
        pendingRequests[room.id]?.contains(where: { $0.userId == currentUserId }
        ) ?? false
    }

    // MARK: - Private Helpers

    private func processSnapshot(_ docs: [QueryDocumentSnapshot]) {
        var tempPending: [String: [ParticipantModel]] = [:]

        self.lobbyRooms = docs.compactMap { doc in
            let roomId = doc.documentID
            let data = doc.data()

            let participants = mapParticipantsData(
                data["participants"] as? [[String: Any]] ?? []
            )
            let pendingList = mapParticipantsData(
                data["pendingRequests"] as? [[String: Any]] ?? []
            )

            tempPending[roomId] = pendingList

            // Check for notifications
            checkForApprovalNotification(
                roomId: roomId,
                currentParticipants: participants,
                data: data
            )

            return SparringRoomModel(
                id: roomId,
                hostId: data["hostId"] as? String ?? "",
                scheduledTime: (data["scheduledTime"] as? Timestamp)?
                    .dateValue() ?? Date(),
                motionTitle: data["motionTitle"] as? String ?? "",
                specialNotes: data["specialNotes"] as? String ?? "",
                meetingLink: data["meetingLink"] as? String ?? "",
                accessType: VisibilityType(
                    rawValue: data["accessType"] as? String ?? "PUBLIC"
                ) ?? .publicAccess,
                state: RoomState(
                    rawValue: data["state"] as? String ?? "PREPARING"
                ) ?? .preparing,
                participants: participants,
                isAdjudicatorNeeded: data["isAdjudicatorNeeded"] as? Bool
                    ?? true
            )
        }
        self.pendingRequests = tempPending
    }

    private func mapParticipantsData(_ data: [[String: Any]])
        -> [ParticipantModel]
    {
        data.compactMap { pData -> ParticipantModel? in
            guard let uid = pData["userId"] as? String,
                let roleStr = pData["roleSlot"] as? String,
                let role = RoleSlotType(rawValue: roleStr),
                let regStr = pData["regMode"] as? String,
                let reg = RegMode(rawValue: regStr)
            else { return nil }
            return ParticipantModel(
                userId: uid,
                userName: pData["userName"] as? String ?? "Unknown",
                roleSlot: role,
                regMode: reg,
                userEmail: pData["userEmail"] as? String
            )
        }
    }

    private func checkForApprovalNotification(
        roomId: String,
        currentParticipants: [ParticipantModel],
        data: [String: Any]
    ) {
        if let previousRoom = self.lobbyRooms.first(where: { $0.id == roomId })
        {
            let wasPending =
                self.pendingRequests[roomId]?.contains(where: {
                    $0.userId == self.currentUserId
                }) ?? false
            let isNowParticipant = currentParticipants.contains(where: {
                $0.userId == self.currentUserId
            })

            if wasPending && isNowParticipant {
                NotificationService.shared.sendNotification(
                    title: "Permintaan Sparring Diterima! 🎉",
                    body:
                        "Host telah menyetujui permintaanmu untuk bergabung di mosi: \(data["motionTitle"] as? String ?? "")"
                )
            }
        }
    }

    // MARK: - Maintenance Methods

    /// Checks for expired rooms and automatically cancels them if empty.
    func checkAndCancelExpiredRooms() {
        let now = Date()
        for room in lobbyRooms {
            if room.scheduledTime <= now && room.state == .preparing {
                let isEmpty = room.participants.isEmpty
                let newState = isEmpty ? "CANCELLED" : "ONGOING"

                db.collection("sparring_rooms").document(room.id).updateData([
                    "state": newState
                ]) { _ in
                    if isEmpty && room.hostId == self.currentUserId {
                        NotificationService.shared.sendNotification(
                            title: "Ruang Sparring Dibatalkan ❌",
                            body:
                                "Ruang sparring mosi '\(room.motionTitle)' otomatis dibatalkan karena tidak ada debater yang bergabung."
                        )
                    }
                }
            }
        }
    }

    /// Cleans up old cancelled or done rooms from Firestore.
    func cleanupOldRooms() {
        db.collection("sparring_rooms")
            .whereField("state", in: ["CANCELLED", "DONE"])
            .getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                for doc in docs { doc.reference.delete() }
            }
    }
}

// MARK: - Extensions for Model Transformation

extension ParticipantModel {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "userId": userId,
            "userName": userName,
            "roleSlot": roleSlot.rawValue,
            "regMode": regMode.rawValue,
        ]
        if let userEmail = userEmail {
            dict["userEmail"] = userEmail
        }
        return dict
    }
}
