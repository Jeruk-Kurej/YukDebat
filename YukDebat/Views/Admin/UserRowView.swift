//
//  UserRowView.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 04-06-2026.
//

import SwiftUI

struct UserRowView: View {
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

#Preview {
    UserRowView(user: UserModel(id: "1", name: "Test User", email: "test@example.com", role: .debater, isActive: true, createdAt: Date())) {}
}
