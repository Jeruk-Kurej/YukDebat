//
//  SparringViewModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

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

    // Antrean Request sekarang Real-time dari Firestore!
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

                    // Parse Peserta yang sudah JOIN
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
                        return ParticipantModel(
                            userId: uid,
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
                        return ParticipantModel(
                            userId: uid,
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
            "isAdjudicatorNeeded": true,  // FIX: Siapkan wadah kosong untuk pending
        ]

        db.collection("sparring_rooms").document(newRoomId).setData(roomData) {
            error in
            if error == nil {
                self.alertMessage = "Ruang sparring berhasil dibuat!"
                self.isShowingCreateRoom = false
                self.formMotionTitle = ""
                self.formMeetingLink = ""
                self.formSpecialNotes = ""
                self.formScheduledTime = Date()
                self.formIsPrivate = false
            }
        }
    }

    // MASUK KE ROOM PUBLIC (LANGSUNG JOIN)
    func joinRoom(room: SparringRoomModel, mode: RegMode) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        if room.participants.contains(where: { $0.userId == userId }) { return }

        let newParticipant: [String: Any] = [
            "userId": userId, "roleSlot": RoleSlotType.openingGovt.rawValue,
            "regMode": mode.rawValue,
        ]
        db.collection("sparring_rooms").document(room.id).updateData([
            "participants": FieldValue.arrayUnion([newParticipant])
        ]) { error in
            if error == nil { self.alertMessage = "Berhasil Join!" }
        }
    }
    func removeParticipant(room: SparringRoomModel, userId: String) {
        let updatedParticipants = room.participants
            .filter { $0.userId != userId }
            .map {
                [
                    "userId": $0.userId, "roleSlot": $0.roleSlot.rawValue,
                    "regMode": $0.regMode.rawValue,
                ]
            }

        db.collection("sparring_rooms").document(room.id).updateData([
            "participants": updatedParticipants
        ])
    }

    // KELUAR DARI ROOM PUBLIC (LEAVE)
    func leaveRoom(roomId: String) {
        guard let userId = Auth.auth().currentUser?.uid,
            let index = lobbyRooms.firstIndex(where: { $0.id == roomId })
        else { return }
        let room = lobbyRooms[index]

        let updatedParticipants = room.participants.filter {
            $0.userId != userId
        }.map {
            [
                "userId": $0.userId, "roleSlot": $0.roleSlot.rawValue,
                "regMode": $0.regMode.rawValue,
            ]
        }
        db.collection("sparring_rooms").document(roomId).updateData([
            "participants": updatedParticipants
        ]) { error in
            if error == nil { self.alertMessage = "Kamu telah keluar." }
        }
    }

    // ---------------------------------------------------------
    // MARK: FITUR PRIVATE ROOM (REQUEST - ACCEPT - CANCEL)
    // ---------------------------------------------------------

    // MENGIRIM REQUEST (PRIVATE ROOM)
    func requestJoin(roomId: String, role: RoleSlotType, isTeam: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let mode: RegMode = isTeam ? .team : .solo
        let newRequest: [String: Any] = [
            "userId": userId, "roleSlot": role.rawValue,
            "regMode": mode.rawValue,
        ]

        db.collection("sparring_rooms").document(roomId).updateData([
            "pendingRequests": FieldValue.arrayUnion([newRequest])
        ]) { error in
            if error == nil {
                self.alertMessage =
                    "Permintaan dikirim! Menunggu persetujuan Host."
            }
        }
    }

    // MEMBATALKAN REQUEST SENDIRI SEBELUM DI-ACCEPT
    func cancelRequest(roomId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let pendingList = pendingRequests[roomId] ?? []
        let updatedPending = pendingList.filter { $0.userId != userId }.map {
            [
                "userId": $0.userId, "roleSlot": $0.roleSlot.rawValue,
                "regMode": $0.regMode.rawValue,
            ]
        }

        db.collection("sparring_rooms").document(roomId).updateData([
            "pendingRequests": updatedPending
        ]) { error in
            if error == nil {
                self.alertMessage = "Permintaan join dibatalkan."
            }
        }
    }

    // HOST MENERIMA REQUEST
    func acceptRequest(roomId: String, participantId: String) {
        guard let pendingList = pendingRequests[roomId],
            let acceptedUser = pendingList.first(where: {
                $0.userId == participantId
            })
        else { return }
        let participantDict = [
            "userId": acceptedUser.userId,
            "roleSlot": acceptedUser.roleSlot.rawValue,
            "regMode": acceptedUser.regMode.rawValue,
        ]
        let updatedPending = pendingList.filter { $0.userId != participantId }
            .map {
                [
                    "userId": $0.userId, "roleSlot": $0.roleSlot.rawValue,
                    "regMode": $0.regMode.rawValue,
                ]
            }

        db.collection("sparring_rooms").document(roomId).updateData([
            "participants": FieldValue.arrayUnion([participantDict]),
            "pendingRequests": updatedPending,
        ])
    }

    // HOST MENOLAK REQUEST
    func rejectRequest(roomId: String, participantId: String) {
        guard let pendingList = pendingRequests[roomId] else { return }
        let updatedPending = pendingList.filter { $0.userId != participantId }
            .map {
                [
                    "userId": $0.userId, "roleSlot": $0.roleSlot.rawValue,
                    "regMode": $0.regMode.rawValue,
                ]
            }

        db.collection("sparring_rooms").document(roomId).updateData([
            "pendingRequests": updatedPending
        ])
    }

    // ---------------------------------------------------------

    func triggerStart(roomId: String) {
        db.collection("sparring_rooms").document(roomId).updateData([
            "state": "ONGOING"
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

    // Fungsi ini untuk membersihkan ruangan yang sudah selesai/batal
    func cleanupOldRooms() {
        let db = Firestore.firestore()

        // Cari ruangan yang statusnya sudah selesai atau batal
        db.collection("sparring_rooms")
            .whereField("state", in: ["CANCELLED", "DONE"])
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    return
                }

                for doc in docs {
                    // Untuk keamanan, kita hapus langsung.
                    // Jika ingin memberi jeda 30 menit (asumsi state diubah saat selesai),
                    // kita bisa menambahkan field 'finishedAt' di masa depan.
                    doc.reference.delete { error in
                        if let error = error {
                            print(
                                "Gagal menghapus room: \(error.localizedDescription)"
                            )
                        } else {
                            print("Room berhasil dibersihkan dari database.")
                        }
                    }
                }
            }
    }
}
