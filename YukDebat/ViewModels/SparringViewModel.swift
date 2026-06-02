//  SparringViewModel.swift
import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation

class SparringViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var lobbyRooms: [SparringRoomModel] = []
    @Published var alertMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isShowingCreateRoom: Bool = false
    @Published var formMotionTitle: String = ""
    @Published var formScheduledTime: Date = Date().addingTimeInterval(3600)
    @Published var formMeetingLink: String = ""
    @Published var formSpecialNotes: String = ""
    @Published var formIsPrivate: Bool = false
    @Published var pendingRequests: [String: [ParticipantModel]] = [:]

    private let dbService: FirestoreServiceProtocol
    private let db = Firestore.firestore()

    var currentUserId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    init(dbService: FirestoreServiceProtocol) {
        self.dbService = dbService
    }

    func listenToRoom(roomId: String) { fetchLobbyRooms() }

    func fetchLobbyRooms() {
        db.collection("sparring_rooms")
            .order(by: "scheduledTime", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let docs = snapshot?.documents else {
                    return
                }

                var tempPending: [String: [ParticipantModel]] = [:]

                self.lobbyRooms = docs.compactMap { doc in
                    let data = doc.data()

                    // Parse Peserta
                    let participantsData =
                        data["participants"] as? [[String: Any]] ?? []
                    let participantsList = participantsData.compactMap {
                        pData -> ParticipantModel? in
                        guard let uid = pData["userId"] as? String,
                            let roleStr = pData["roleSlot"] as? String,
                            let role = RoleSlotType(rawValue: roleStr),
                            let regStr = pData["regMode"] as? String,
                            let reg = RegMode(rawValue: regStr)
                        else { return nil }
                        let name = pData["userName"] as? String ?? "Unknown"
                        return ParticipantModel(
                            userId: uid,
                            userName: name,
                            roleSlot: role,
                            regMode: reg
                        )
                    }

                    // Parse Antrean PENDING REQUEST
                    let pendingData =
                        data["pendingRequests"] as? [[String: Any]] ?? []
                    let pendingList = pendingData.compactMap {
                        pData -> ParticipantModel? in
                        guard let uid = pData["userId"] as? String,
                            let roleStr = pData["roleSlot"] as? String,
                            let role = RoleSlotType(rawValue: roleStr),
                            let regStr = pData["regMode"] as? String,
                            let reg = RegMode(rawValue: regStr)
                        else { return nil }
                        let name = pData["userName"] as? String ?? "Unknown"
                        return ParticipantModel(
                            userId: uid,
                            userName: name,
                            roleSlot: role,
                            regMode: reg
                        )
                    }

                    tempPending[doc.documentID] = pendingList

                    return SparringRoomModel(
                        id: doc.documentID,
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
                        participants: participantsList,
                        isAdjudicatorNeeded: data["isAdjudicatorNeeded"]
                            as? Bool ?? true
                    )
                }
                self.pendingRequests = tempPending
            }
    }

    func isUserInRoom(room: SparringRoomModel) -> Bool {
        return room.participants.contains(where: { $0.userId == currentUserId })
    }

    func isUserHost(room: SparringRoomModel) -> Bool {
        return room.hostId == currentUserId
    }

    func isUserPending(room: SparringRoomModel) -> Bool {
        return pendingRequests[room.id]?.contains(where: {
            $0.userId == currentUserId
        }) ?? false
    }

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
            "id": newRoomId, "hostId": userId,
            "scheduledTime": Timestamp(date: self.formScheduledTime),
            "motionTitle": self.formMotionTitle.isEmpty
                ? "Topik Bebas" : self.formMotionTitle,
            "specialNotes": self.formSpecialNotes,
            "meetingLink": self.formMeetingLink,
            "accessType": self.formIsPrivate ? "PRIVATE" : "PUBLIC",
            "state": "PREPARING",
            "participants": [], "pendingRequests": [],
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

    func joinRoom(room: SparringRoomModel, mode: RegMode) {
        guard let userId = Auth.auth().currentUser?.uid,
            let name = Auth.auth().currentUser?.displayName
        else { return }

        let newParticipant: [String: Any] = [
            "userId": userId,
            "userName": name,
            "roleSlot": RoleSlotType.openingGovt.rawValue,
            "regMode": mode.rawValue,
        ]

        db.collection("sparring_rooms").document(room.id).updateData([
            "participants": FieldValue.arrayUnion([newParticipant])
        ]) { error in
            if error == nil { self.alertMessage = "Berhasil Join!" }
        }
    }

    func requestJoin(roomId: String, role: RoleSlotType, isTeam: Bool) {
        let userName = Auth.auth().currentUser?.displayName ?? "Debater"
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let mode: RegMode = isTeam ? .team : .solo
        let newRequest: [String: Any] = [
            "userId": userId,
            "userName": userName,  // Sekarang mengirimkan nama
            "roleSlot": role.rawValue,
            "regMode": mode.rawValue,
        ]

        db.collection("sparring_rooms").document(roomId).updateData([
            "pendingRequests": FieldValue.arrayUnion([newRequest])
        ]) { error in
            if error == nil { self.alertMessage = "Permintaan dikirim!" }
        }
    }

    func acceptRequest(roomId: String, participantId: String) {
        guard let pendingList = pendingRequests[roomId],
            let acceptedUser = pendingList.first(where: {
                $0.userId == participantId
            })
        else { return }

        let participantDict = [
            "userId": acceptedUser.userId,
            "userName": acceptedUser.userName,
            "roleSlot": acceptedUser.roleSlot.rawValue,
            "regMode": acceptedUser.regMode.rawValue,
        ]

        let updatedPending = pendingList.filter { $0.userId != participantId }
            .map {
                [
                    "userId": $0.userId, "userName": $0.userName,
                    "roleSlot": $0.roleSlot.rawValue,
                    "regMode": $0.regMode.rawValue,
                ]
            }

        db.collection("sparring_rooms").document(roomId).updateData([
            "participants": FieldValue.arrayUnion([participantDict]),
            "pendingRequests": updatedPending,
        ])
    }

    // ... (Fungsi lain seperti rejectRequest, cancelRequest, dll tetap sama, pastikan saja mapping datanya menyertakan userName)

    func rejectRequest(roomId: String, participantId: String) {
        guard let pendingList = pendingRequests[roomId] else { return }
        let updatedPending = pendingList.filter { $0.userId != participantId }
            .map {
                [
                    "userId": $0.userId, "userName": $0.userName,
                    "roleSlot": $0.roleSlot.rawValue,
                    "regMode": $0.regMode.rawValue,
                ]
            }
        db.collection("sparring_rooms").document(roomId).updateData([
            "pendingRequests": updatedPending
        ])
    }

    func cancelRequest(roomId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let pendingList = pendingRequests[roomId] ?? []
        let updatedPending = pendingList.filter { $0.userId != userId }.map {
            [
                "userId": $0.userId, "userName": $0.userName,
                "roleSlot": $0.roleSlot.rawValue,
                "regMode": $0.regMode.rawValue,
            ]
        }
        db.collection("sparring_rooms").document(roomId).updateData([
            "pendingRequests": updatedPending
        ])
    }

    func leaveRoom(roomId: String) {
        guard let userId = Auth.auth().currentUser?.uid,
            let index = lobbyRooms.firstIndex(where: { $0.id == roomId })
        else { return }
        let room = lobbyRooms[index]
        let updatedParticipants = room.participants.filter {
            $0.userId != userId
        }.map {
            [
                "userId": $0.userId, "userName": $0.userName,
                "roleSlot": $0.roleSlot.rawValue,
                "regMode": $0.regMode.rawValue,
            ]
        }
        db.collection("sparring_rooms").document(roomId).updateData([
            "participants": updatedParticipants
        ])
    }

    func removeParticipant(room: SparringRoomModel, userId: String) {
        let updatedParticipants = room.participants.filter {
            $0.userId != userId
        }.map {
            [
                "userId": $0.userId, "userName": $0.userName,
                "roleSlot": $0.roleSlot.rawValue,
                "regMode": $0.regMode.rawValue,
            ]
        }
        db.collection("sparring_rooms").document(room.id).updateData([
            "participants": updatedParticipants
        ])
    }

    func checkAndCancelExpiredRooms() {
        let now = Date()
        for room in lobbyRooms {
            if room.scheduledTime <= now && room.state == .preparing {
                let newState =
                    room.participants.isEmpty ? "CANCELLED" : "ONGOING"
                db.collection("sparring_rooms").document(room.id).updateData([
                    "state": newState
                ])
            }
        }
    }

    func cleanupOldRooms() {
        db.collection("sparring_rooms").whereField(
            "state",
            in: ["CANCELLED", "DONE"]
        ).getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            for doc in docs { doc.reference.delete() }
        }
    }
}
