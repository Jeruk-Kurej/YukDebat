//
//  SparringViewModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import Combine
import Foundation

/// Coordinates the real-time sparring lobby state and matchmaking intents.
class SparringViewModel: ObservableObject {

    // MARK: - Published Properties (UI State)
    @Published var lobbyRooms: [SparringRoomModel] = []
    @Published var alertMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isShowingCreateRoom: Bool = false

    // MARK: - Published Properties (Form Data)
    @Published var formMotionTitle: String = "" // PENGGANTI KATEGORI
    @Published var formScheduledTime: Date = Date().addingTimeInterval(3600)
    @Published var formMeetingLink: String = ""
    @Published var formSpecialNotes: String = ""
    @Published var formIsPrivate: Bool = false
    @Published var pendingRequests: [String: [ParticipantModel]] = [:]

    // MARK: - Private Properties
    private let currentUserId = "user_me"
    private let dbService: FirestoreServiceProtocol

    init(dbService: FirestoreServiceProtocol) {
        self.dbService = dbService
    }

    // MARK: - Methods
    func listenToRoom(roomId: String) {
        let roomPublic = SparringRoomModel(
            id: "room_public_1", hostId: "user_mario_123", scheduledTime: Date().addingTimeInterval(7200),
            motionTitle: "Dewan ini akan melarang penggunaan AI sebagai instrumen kelulusan",
            specialNotes: "Latihan BP standar NUDC.", meetingLink: "https://zoom.us/j/dummy",
            accessType: .publicAccess, state: .preparing, participants: [], isAdjudicatorNeeded: true
        )
        self.lobbyRooms = [roomPublic]
    }

    func isUserInRoom(room: SparringRoomModel) -> Bool {
        return room.participants.contains(where: { $0.userId == currentUserId })
    }

    func isUserHost(room: SparringRoomModel) -> Bool {
        return room.hostId == currentUserId
    }

    func isUserPending(room: SparringRoomModel) -> Bool {
        return pendingRequests[room.id]?.contains(where: { $0.userId == currentUserId }) ?? false
    }

    func submitRoomForm() {
        guard !formMeetingLink.isEmpty else {
            self.errorMessage = "Meeting Link tidak boleh kosong."
            return
        }
        let newRoom = SparringRoomModel(
            id: UUID().uuidString, hostId: self.currentUserId, scheduledTime: self.formScheduledTime,
            motionTitle: self.formMotionTitle.isEmpty ? "Topik Bebas" : self.formMotionTitle,
            specialNotes: self.formSpecialNotes, meetingLink: self.formMeetingLink,
            accessType: self.formIsPrivate ? .privateAccess : .publicAccess,
            state: .preparing, participants: [], isAdjudicatorNeeded: true
        )
        self.lobbyRooms.insert(newRoom, at: 0)
        self.isShowingCreateRoom = false
        self.formMotionTitle = ""
        self.alertMessage = "Ruang sparring berhasil dibuat!"
    }

    func requestJoin(roomId: String, role: RoleSlotType, isTeam: Bool) {
        guard let index = lobbyRooms.firstIndex(where: { $0.id == roomId }) else { return }
        let room = lobbyRooms[index]

        if room.participants.count >= 8 {
            self.errorMessage = "Ruangan sudah penuh."
            return
        }

        let regMode: RegMode = isTeam ? .team : .solo
        let newParticipant = ParticipantModel(userId: currentUserId, roleSlot: role, regMode: regMode)
        let teammate = ParticipantModel(userId: "rekan_tim_anda", roleSlot: role, regMode: regMode)

        if room.accessType == .privateAccess {
            var currentPending = pendingRequests[roomId] ?? []
            currentPending.append(newParticipant)
            if isTeam { currentPending.append(teammate) }
            pendingRequests[roomId] = currentPending
            self.alertMessage = "Permintaan dikirim! Menunggu persetujuan."
        } else {
            self.lobbyRooms[index].participants.append(newParticipant)
            if isTeam { self.lobbyRooms[index].participants.append(teammate) }
            self.alertMessage = isTeam ? "Berhasil bergabung (2 Slot)!" : "Berhasil bergabung!"
        }
    }

    func acceptRequest(roomId: String, participantId: String) {
        guard let roomIndex = lobbyRooms.firstIndex(where: { $0.id == roomId }) else { return }
        guard let pendingList = pendingRequests[roomId] else { return }

        let matchedRequests = pendingList.filter { $0.userId == participantId || $0.userId == "rekan_tim_anda" }
        for participant in matchedRequests {
            lobbyRooms[roomIndex].participants.append(participant)
        }
        pendingRequests[roomId]?.removeAll(where: { $0.userId == participantId || $0.userId == "rekan_tim_anda" })
    }

    func rejectRequest(roomId: String, participantId: String) {
        pendingRequests[roomId]?.removeAll(where: { $0.userId == participantId || $0.userId == "rekan_tim_anda" })
    }

    /// AKTIFASI FITUR LEAVE ROOM (Perbaikan Revisi)
    func leaveRoom(roomId: String) {
        guard let index = lobbyRooms.firstIndex(where: { $0.id == roomId }) else { return }
        self.lobbyRooms[index].participants.removeAll(where: {
            $0.userId == self.currentUserId || $0.userId == "rekan_tim_anda"
        })
        self.alertMessage = "Kamu telah keluar dari ruang sparring."
    }

    func triggerStart(roomId: String) {
        guard let index = lobbyRooms.firstIndex(where: { $0.id == roomId }) else { return }
        self.lobbyRooms[index].state = .ongoing
    }
}
