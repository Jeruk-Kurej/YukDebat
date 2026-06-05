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
                        if room.accessType == .privateAccess {
                            pendingRequestsSection
                        }
                        participantsSection
                    }
                    .scrollContentBackground(.hidden)

                    if room.state == .preparing || room.state == .ongoing {
                        EndSparringButtonView(action: {
                            viewModel.completeRoom(roomId: room.id)
                            dismiss()
                        })
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
                Text("Are you sure you want to remove this participant?")
            }
        }
    }

    // MARK: - Sections

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
            Picker("Visibility", selection: Binding(
                get: { room.accessType },
                set: { newValue in
                    viewModel.updateVisibility(roomId: room.id, newVisibility: newValue)
                }
            )) {
                Text("Public").tag(VisibilityType.publicAccess)
                Text("Private").tag(VisibilityType.privateAccess)
            }
            .pickerStyle(.menu)
        }
        .listRowBackground(Color.white)
    }

    private var pendingRequestsSection: some View {
        Section(header: Text("Pending Requests").font(.caption.bold())) {
            // Kita akses dictionary pendingRequests dari ViewModel
            let pendingList = viewModel.pendingRequests[room.id] ?? []

            if pendingList.isEmpty {
                Text("No pending requests.").foregroundStyle(.secondary)
                    .italic()
            } else {
                ForEach(pendingList) { participant in
                    PendingRequestRowView(
                        participant: participant,
                        onReject: {
                            viewModel.rejectRequest(
                                roomId: room.id,
                                participantId: participant.userId
                            )
                        },
                        onApprove: {
                            if participant.regMode == .team && room.totalSlotsFilled() > 6 {
                                viewModel.errorMessage = "Not enough slots for a team."
                            } else if room.isRoomFull() {
                                viewModel.errorMessage = "Room is full."
                            } else {
                                viewModel.acceptRequest(
                                    roomId: room.id,
                                    participantId: participant.userId
                                )
                            }
                        }
                    )
                }
            }
        }
        .listRowBackground(Color.white)
    }

    private var participantsSection: some View {
        Section(
            header: Text("Active Participants (\(room.totalSlotsFilled())/8)")
                .font(.caption.bold())
        ) {
            if room.participants.isEmpty {
                Text("No one has joined yet.").foregroundStyle(.secondary)
                    .italic()
            } else {
                ForEach(room.participants) { participant in
                    SparringParticipantRowView(
                        participant: participant,
                        isCurrentUser: participant.userId
                            == viewModel.currentUserId
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            participantToRemove = participant
                            showRemoveAlert = true
                        } label: {
                            Label(
                                "Remove Participant",
                                systemImage: "person.badge.minus"
                            )
                        }
                    }
                }
            }
        }
        .listRowBackground(Color.white)
    }
}
