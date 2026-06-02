//
//  AdminAdjudicatorRow.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct UserManagementView: View {
    @ObservedObject var viewModel: ModerationDashboardViewModel
    @Binding var userToManage: UserModel?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                // User Management
                Text("User Management")
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                ForEach(viewModel.allUsers) { user in
                    UserRow(user: user, onAction: { userToManage = user })
                }
                
                Divider().padding(.vertical, 16)
                
                // Content Moderation
                Text("Public Notes Moderation")
                    .font(.subheadline.bold())
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                ForEach(viewModel.publicNotes) { note in
                    NoteModerationRow(note: note) {
                        viewModel.hidePublicNote(noteId: note.id)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// Komponen Reusable Kecil untuk Tab ini
struct UserRow: View {
    let user: UserModel
    let onAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(user.name).font(.headline)
                Text(user.email).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if user.role == .admin {
                Text("ADMIN").font(.caption.bold()).foregroundStyle(.gray)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1)).clipShape(Capsule())
            } else {
                Button(action: onAction) {
                    Text(user.isActive ? "Suspend" : "Unsuspend")
                        .font(.caption.bold()).foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(user.isActive ? Color.btnNegative : Color.btnPositive)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
}

struct NoteModerationRow: View {
    let note: CaseBuildingNoteModel
    let onHide: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(note.motionTitle).font(.headline).lineLimit(1)
                Text("ID: \(note.id)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onHide) {
                Image(systemName: "eye.slash.fill").foregroundStyle(Color.btnNegative)
            }
        }
        .padding(16).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
}
