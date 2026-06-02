//
//  SparringRoomCard.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct SparringRoomCard: View {
    let room: SparringRoomModel
    @ObservedObject var viewModel: SparringViewModel

    @State private var showManageSheet = false
    @State private var showJoinOptions = false
    @State private var showLeaveAlert = false
    @State private var showCancelAlert = false  // FIX: Tambahan state untuk Cancel Request

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerSection
            bodySection

            Divider()
                .padding(.vertical, 2)

            footerSection
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                Color.black.opacity(0.04),
                lineWidth: 1
            )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)

        // 1. Dialog Join
        .confirmationDialog(
            room.accessType == .privateAccess
                ? "Request to Join" : "Join Sparring",
            isPresented: $showJoinOptions
        ) {
            Button("Solo") {
                if room.accessType == .privateAccess {
                    viewModel.requestJoin(
                        roomId: room.id,
                        role: .openingGovt,
                        isTeam: false
                    )
                } else {
                    viewModel.joinRoom(room: room, mode: .solo)
                }
            }
            Button("Team") {
                if room.accessType == .privateAccess {
                    viewModel.requestJoin(
                        roomId: room.id,
                        role: .openingGovt,
                        isTeam: true
                    )
                } else {
                    viewModel.joinRoom(room: room, mode: .team)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                room.accessType == .privateAccess
                    ? "Choose registration mode to send a request."
                    : "Choose your registration mode to join this room."
            )
        }

        // 2. Alert Leave Room
        .alert("Leave Room", isPresented: $showLeaveAlert) {
            Button("Leave", role: .destructive) {
                viewModel.leaveRoom(roomId: room.id)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to leave this sparring room?")
        }

        // 3. Alert Cancel Request (FIX)
        .alert("Cancel Request", isPresented: $showCancelAlert) {
            Button("Cancel Request", role: .destructive) {
                viewModel.cancelRequest(roomId: room.id)
            }
            Button("Keep Waiting", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel your join request?")
        }

        // 4. Sheet Manage Room
        .sheet(isPresented: $showManageSheet) {
            ManageSparringRoomView(room: room, viewModel: viewModel)
        }
    }

    // MARK: - Sub-Views

    private var headerSection: some View {
        HStack {
            // Status Badge
            HStack(spacing: 6) {
                Circle().fill(stateColor).frame(width: 8, height: 8)
                Text(room.state.rawValue)
                    .font(.caption2.bold())
                    .foregroundStyle(Color.textCharcoal)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.gray.opacity(0.1))
            .clipShape(Capsule())

            Spacer()

            // Time Info
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                Text(
                    room.scheduledTime.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
            }
            .font(.caption.bold())
            .foregroundStyle(.secondary)
        }
    }

    // Di dalam file SparringRoomCard.swift

    private var bodySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(room.motionTitle)
                .font(.headline)
                .foregroundStyle(Color.textCharcoal)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // TAMPILKAN NOTES JIKA ADA
            if !room.specialNotes.isEmpty {
                Text("Notes: \(room.specialNotes)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
                    .padding(.top, 2)
            }

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "number.square.fill")
                    Text(room.id.prefix(6).uppercased())
                }

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                    Text("\(room.participants.count)/8 Joined")
                }
                .foregroundStyle(
                    room.participants.count >= 8
                        ? Color.btnNegative : .secondary
                )
            }
            .font(.caption.bold())
            .foregroundStyle(.secondary)
            .padding(.top, 2)
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if room.state == .cancelled || room.state == .done {
            Text(room.state.rawValue).font(.subheadline.bold()).foregroundStyle(
                .gray
            )
        } else if viewModel.isUserHost(room: room) {
            Button("Manage") { showManageSheet = true }
                .font(.subheadline.bold()).foregroundStyle(.white)
                .padding(.horizontal, 16).padding(.vertical, 8).background(
                    Color.accentWalnut
                )
                .clipShape(Capsule())
        } else if viewModel.isUserPending(room: room) {
            Button("Cancel Request") { showCancelAlert = true }
                .font(.subheadline.bold()).foregroundStyle(Color.btnNegative)
        } else if viewModel.isUserInRoom(room: room) {
            // --- REVISI: TOMBOL JOIN MEETING ---
            HStack(spacing: 8) {
                Button(action: { showLeaveAlert = true }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
                .foregroundStyle(Color.btnNegative)

                Button("Join Meeting") {
                    if let url = URL(string: room.meetingLink) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.subheadline.bold()).foregroundStyle(.white)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Color.btnPositive)
                .clipShape(Capsule())
            }
        } else {
            Button(room.accessType == .privateAccess ? "Request" : "Join") {
                showJoinOptions = true
            }
            .font(.subheadline.bold()).foregroundStyle(.white)
            .padding(.horizontal, 16).padding(.vertical, 8).background(
                Color.btnPositive
            )
            .clipShape(Capsule())
        }
    }

    private var footerSection: some View {
        HStack {
            participantBadge
            Spacer()
            actionButton
        }
    }

    @ViewBuilder
    private var participantBadge: some View {
        // FIX: Deteksi jika sudah Join di dalam Room
        if viewModel.isUserInRoom(room: room),
            let myParticipant = room.participants.first(where: {
                $0.userId == viewModel.currentUserId
            })
        {
            badgeView(
                text: "Joined: \(myParticipant.regMode.rawValue.capitalized)",
                color: Color.btnPositive
            )
        }
        // FIX: Deteksi jika masih Pending Request (Private Room)
        else if viewModel.isUserPending(room: room),
            let pendingList = viewModel.pendingRequests[room.id],
            let myPending = pendingList.first(where: {
                $0.userId == viewModel.currentUserId
            })
        {
            badgeView(
                text: "Pending: \(myPending.regMode.rawValue.capitalized)",
                color: .orange
            )
        }
    }

    private func badgeView(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var stateColor: Color {
        switch room.state {
        case .ongoing: return .red
        case .cancelled: return .gray
        default: return Color.btnPositive
        }
    }
}

// MARK: - Preview

#Preview {
    SparringRoomCard(
        room: SparringRoomModel(
            id: "room_public_1",
            hostId: "user_mario_123",
            scheduledTime: Date().addingTimeInterval(7200),
            motionTitle: "Education",
            specialNotes: "Standard BP practice.",
            meetingLink: "https://zoom.us/j/dummy",
            accessType: .publicAccess,
            state: .preparing,
            participants: [],
            isAdjudicatorNeeded: true
        ),
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
    .padding()
    .background(Color.bgCream)
}
