//
//  UserManagementView.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 04-06-2026.
//

import SwiftUI

struct UserManagementView: View {
    @ObservedObject var viewModel: ModerationDashboardViewModel
    @Binding var userToManage: UserModel?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                Text("User Management")
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                ForEach(viewModel.allUsers) { user in
                    UserRowView(user: user, onAction: { userToManage = user })
                }
                
                Divider().padding(.vertical, 16)
                
                Text("Public Notes Moderation")
                    .font(.subheadline.bold())
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                ForEach(viewModel.publicNotes) { note in
                    NoteModerationRowView(note: note) {
                        viewModel.hidePublicNote(noteId: note.id)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}



#Preview {
    UserManagementView(
        viewModel: ModerationDashboardViewModel(),
        userToManage: .constant(nil)
    )
}
