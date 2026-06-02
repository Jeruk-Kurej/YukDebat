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
                List {
                    Section(header: Text("Room Status").font(.caption.bold())) {
                        HStack {
                            Text("Current State")
                            Spacer()
                            Text(room.state.rawValue.capitalized)
                                .font(.subheadline.bold())
                                .foregroundStyle(
                                    room.state == .ongoing
                                        ? Color.red : Color.btnPositive
                                )
                        }
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text(
                            "Active Participants (\(room.participants.count)/8)"
                        ).font(.caption.bold())
                    ) {
                        if room.participants.isEmpty {
                            Text("No one has joined yet.").foregroundStyle(
                                .secondary
                            ).italic()
                        } else {
                            ForEach(room.participants) { participant in
                                HStack(spacing: 12) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.accentWalnut)

                                    VStack(alignment: .leading) {
                                        Text(
                                            participant.userId
                                                == viewModel.currentUserId
                                                ? "You" : "Debater"
                                        )
                                        .font(.subheadline.bold())
                                        Text("user@example.com")
                                            .font(.caption).foregroundStyle(
                                                .secondary
                                            )
                                    }
                                    Spacer()
                                    Text(
                                        participant.regMode.rawValue.capitalized
                                    )
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 8).padding(
                                        .vertical,
                                        4
                                    )
                                    .background(Color.accentWalnut.opacity(0.1))
                                    .foregroundStyle(Color.accentWalnut)
                                    .clipShape(Capsule())
                                }
                                .padding(.vertical, 4)
                                .contextMenu {
                                    Button(
                                        role: .destructive,
                                        action: {
                                            self.participantToRemove =
                                                participant
                                            self.showRemoveAlert = true
                                        }
                                    ) {
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
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Manage Room")
            .navigationBarTitleDisplayMode(.inline)
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
            } message: { participant in
                Text(
                    "Are you sure you want to remove this participant from the room?"
                )
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
