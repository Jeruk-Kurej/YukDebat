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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            contentSection
            Divider()
            footerSection
        }
        .padding(16).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
        .sheet(isPresented: $showManageSheet) { ManageSparringRoomView(room: room, viewModel: viewModel) }
        .confirmationDialog("Join Sparring Room", isPresented: $showJoinOptions, titleVisibility: .visible) {
            Button("Join as Solo") { viewModel.requestJoin(roomId: room.id, role: .openingGovt, isTeam: false) }
            Button("Join as Team (2 Persons)") { viewModel.requestJoin(roomId: room.id, role: .openingGovt, isTeam: true) }
            Button("Cancel", role: .cancel) {}
        } message: { Text("How would you like to register for this session?") }
        .alert("Leave Room", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) { viewModel.leaveRoom(roomId: room.id) }
        } message: { Text("Are you sure you want to leave this sparring session?") }
        .padding(.horizontal, 20)
    }
    
    private var headerSection: some View {
        HStack {
            HStack(spacing: 6) {
                Circle().fill(room.state == .ongoing ? Color.red : Color.btnPositive).frame(width: 8, height: 8)
                Text(room.state.rawValue).font(.caption2.bold()).foregroundStyle(Color.textCharcoal)
            }
            .padding(.horizontal, 8).padding(.vertical, 4).background(Color.gray.opacity(0.1)).clipShape(Capsule())
            Spacer()
            Text(room.scheduledTime.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(.secondary)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(room.motionTitle).font(.system(.headline, design: .serif)).foregroundStyle(Color.textCharcoal)
            Text(room.specialNotes).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
        }
    }
    
    private var footerSection: some View {
        HStack {
            Text("\(room.participants.count)/8 Joined").font(.caption).foregroundStyle(.secondary)
            Spacer()
            actionButton
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        if viewModel.isUserHost(room: room) {
            Button("Manage") { showManageSheet = true }.font(.subheadline.bold()).foregroundStyle(.white)
                .padding(.horizontal, 16).padding(.vertical, 8).background(Color.accentWalnut).clipShape(Capsule())
        } else if viewModel.isUserInRoom(room: room) {
            Button("Leave") { showLeaveAlert = true }.font(.subheadline.bold()).foregroundStyle(Color.btnNegative)
        } else {
            Button("Join") { showJoinOptions = true }.font(.subheadline.bold()).foregroundStyle(.white)
                .padding(.horizontal, 16).padding(.vertical, 8).background(Color.btnPositive).clipShape(Capsule())
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
