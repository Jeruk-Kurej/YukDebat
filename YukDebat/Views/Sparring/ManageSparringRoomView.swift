//
//  ManageSparringRoomView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct ManageSparringRoomView: View {
    let room: SparringRoomModel
    @ObservedObject var viewModel: SparringViewModel
    @Environment(\.dismiss) var dismiss

    @State private var participantToRemove: ParticipantModel? = nil
    @State private var showRemoveAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    List {
                        statusSection
                        pendingRequestsSection
                        participantsSection
                    }
                    .scrollContentBackground(.hidden)

                    // REVISI: Tombol Aksi untuk Mengakhiri Sesi Debat (End Sparring)
                    if room.state == .preparing || room.state == .ongoing {
                        Button(action: {
                            viewModel.completeRoom(roomId: room.id)
                            dismiss()  // Otomatis menutup sheet setelah room selesai
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                Text("End Sparring Session")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.btnNegative)  // Menggunakan warna merah aksen pembatalan/selesai
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Manage Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundStyle(
                        Color.textCharcoal
                    )
                }
            }
            .alert(
                "Remove Participant",
                isPresented: $showRemoveAlert,
                presenting: participantToRemove
            ) { participant in
                Button("Remove", role: .destructive) {
                    viewModel.removeParticipant(
                        room: room,
                        userId: participant.userId
                    )
                }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text(
                    "Are you sure you want to remove this participant from the room?"
                )
            }
        }
    }

    // MARK: - Sub-Sections (Agar Compiler tidak pusing)

    private var statusSection: some View {
        Section(header: Text("Room Status").font(.caption.bold())) {
            HStack {
                Text("Current State")
                Spacer()
                Text(room.state.rawValue.capitalized)
                    .font(.subheadline.bold())
                    .foregroundStyle(
                        room.state == .ongoing ? Color.red : Color.btnPositive
                    )
            }
        }
        .listRowBackground(Color.white)
    }

    private var pendingRequestsSection: some View {
        Section(header: Text("Pending Requests").font(.caption.bold())) {
            let pendingList = viewModel.pendingRequests[room.id] ?? []
            if pendingList.isEmpty {
                Text("No pending requests.").foregroundStyle(.secondary)
                    .italic()
            } else {
                ForEach(pendingList) { participant in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(participant.userName).font(
                                .subheadline.bold()
                            )
                        }
                        Spacer()
                        Button(action: {
                            viewModel.rejectRequest(
                                roomId: room.id,
                                participantId: participant.userId
                            )
                        }) {
                            Image(systemName: "xmark.circle.fill").font(.title2)
                                .foregroundStyle(Color.btnNegative)
                        }.buttonStyle(PlainButtonStyle())

                        Button(action: {
                            viewModel.acceptRequest(
                                roomId: room.id,
                                participantId: participant.userId
                            )
                        }) {
                            Image(systemName: "checkmark.circle.fill").font(
                                .title2
                            ).foregroundStyle(Color.btnPositive)
                        }.buttonStyle(PlainButtonStyle()).padding(.leading, 8)
                    }
                }
            }
        }
        .listRowBackground(Color.white)
    }

    private var participantsSection: some View {
        Section(
            header: Text("Active Participants (\(room.participants.count)/8)")
                .font(.caption.bold())
        ) {
            if room.participants.isEmpty {
                Text("No one has joined yet.").foregroundStyle(.secondary)
                    .italic()
            } else {
                ForEach(room.participants) { participant in
                    participantRow(participant)
                }
            }
        }
        .listRowBackground(Color.white)
    }

    private func participantRow(_ participant: ParticipantModel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.accentWalnut)

            VStack(alignment: .leading) {
                // SINKRONISASI: Tampilkan nama debater yang asli
                Text(
                    participant.userId == viewModel.currentUserId
                        ? "You (\(participant.userName))" : participant.userName
                )
                .font(.subheadline.bold())
                Text("user@example.com")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(participant.regMode.rawValue.capitalized)
                .font(.caption2.bold())
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.accentWalnut.opacity(0.1))
                .foregroundStyle(Color.accentWalnut)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
        .workspaceContextMenu(participant: participant)
    }
}

// Extension pembantu untuk context menu agar kode tetap SOLID dan bersih
extension View {
    @ViewBuilder
    func workspaceContextMenu(participant: ParticipantModel) -> some View {
        self.contextMenu {
            Button(
                role: .destructive,
                action: {
                    // Penanganan logika hapus di view utama diurus lewat binding state
                    NotificationCenter.default.post(
                        name: NSNotification.Name("TriggerRemoveAlert"),
                        object: participant
                    )
                }
            ) {
                Label("Remove Participant", systemImage: "person.badge.minus")
            }
        }
    }
}

#Preview {
    ManageSparringRoomView(
        room: SparringRoomModel(
            id: "1",
            hostId: "u1",
            scheduledTime: Date(),
            motionTitle: "Test",
            specialNotes: "",
            meetingLink: "",
            accessType: .privateAccess,
            state: .preparing,
            participants: [],
            isAdjudicatorNeeded: false
        ),
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
}
