//
//  ProfileView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            List {
                // Header Profil
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.accentWalnut)
                        VStack(alignment: .leading) {
                            Text(authVM.currentUser?.name ?? "User")
                                .font(.headline)
                            Text(authVM.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // SECTION SPARRING FEEDBACK SUDAH DIHAPUS (Dihilangkan dari list)
                
                Section("Account") {
                    Button("Log Out", role: .destructive) {
                        authVM.logout()
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
