//
//  ProfileView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 29/05/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 1. HEADER PROFIL
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(
                                    Color.accentWalnut.opacity(0.8)
                                )
                                .background(
                                    Circle().fill(Color.white).shadow(radius: 5)
                                )

                            VStack(spacing: 4) {
                                Text("Bryan Carlie L.")
                                    .font(.title2.bold())
                                    .foregroundStyle(Color.textCharcoal)
                                Text("bcarlielukito@student.ciputra.ac.id")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                Text("Debater Premium")
                            }
                            .font(.caption.bold())
                            .foregroundStyle(Color.btnPositive)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.btnPositive.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 20)

                        // 2. MENU PENGATURAN
                        VStack(spacing: 0) {
                            ProfileMenuRow(
                                icon: "person.text.rectangle",
                                title: "Edit Informasi Akun"
                            )
                            Divider().padding(.leading, 40)
                            ProfileMenuRow(
                                icon: "bell.badge.fill",
                                title: "Notifikasi Sistem"
                            )
                            Divider().padding(.leading, 40)
                            ProfileMenuRow(
                                icon: "doc.text.fill",
                                title: "Syarat & Ketentuan (TOS)"
                            )
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16).stroke(
                                Color.black.opacity(0.04),
                                lineWidth: 1
                            )
                        )

                        // 3. LOGOUT BUTTON
                        Button(action: { showLogoutAlert = true }) {
                            Text("Keluar (Log Out)")
                                .font(.headline)
                                .foregroundStyle(Color.btnNegative)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16).stroke(
                                        Color.btnNegative.opacity(0.3),
                                        lineWidth: 1
                                    )
                                )
                        }
                        .alert(
                            "Keluar dari Akun",
                            isPresented: $showLogoutAlert
                        ) {
                            Button("Batal", role: .cancel) {}
                            Button("Keluar", role: .destructive)
                            { /* Logika hapus sesi */  }
                        } message: {
                            Text(
                                "Apakah Anda yakin ingin keluar dari aplikasi YukDebat?"
                            )
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Profil Saya")
        }
    }
}

// Subkomponen Menu
struct ProfileMenuRow: View {
    let icon: String
    let title: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentWalnut)
                .frame(width: 24)
            Text(title)
                .font(.system(.body, design: .default, weight: .medium))
                .foregroundStyle(Color.textCharcoal)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(Color.gray.opacity(0.5))
        }
        .padding()
    }
}

#Preview { ProfileView() }
