//
//  ProfileView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct ProfileView: View {

    // MARK: - Properties

    @EnvironmentObject var authVM: AuthViewModel

    @StateObject private var adjReqVM = AdjudicatorRequestViewModel(
        storageService: CloudinaryService()
    )

    @State private var showLogoutAlert = false
    @State private var showAdjudicatorForm = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        settingsSection
                        logoutButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("My Profile")
            .onAppear {
                adjReqVM.checkExistingRequest()
            }
            .sheet(isPresented: $showAdjudicatorForm) {
                ApplyAdjudicatorFormView(viewModel: adjReqVM)
            }
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    authVM.logout()
                }
            } message: {
                Text("Are you sure you want to log out from YukDebat?")
            }
            .modernToast(
                message: $adjReqVM.statusMessage,
                isError: adjReqVM.statusMessage?.contains("Failed") == true
            )
        }
    }

    // MARK: - Sub-Sections

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(Color.accentWalnut.opacity(0.8))
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.05),
                            radius: 10,
                            y: 5
                        )
                )

            VStack(spacing: 4) {
                Text(authVM.currentUser?.name ?? "YukDebat User")
                    .font(.title2.bold())
                    .foregroundStyle(Color.textCharcoal)

                Text(authVM.currentUser?.email ?? "Fetching email...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 16)
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: EditProfileView()) {
                ProfileMenuRowView(
                    icon: "person.text.rectangle",
                    title: "Edit Account Information"
                )
            }
            .buttonStyle(.plain)
            
            if authVM.currentUser?.role == .debater {
                Divider().padding(.leading, 40)

                Button(action: { showAdjudicatorForm = true }) {
                    adjudicatorMenuRow
                }
                .disabled(adjReqVM.hasPendingRequest)
                .buttonStyle(.plain)
            }

            Divider().padding(.leading, 40)

            NavigationLink(destination: TermsOfServiceView()) {
                ProfileMenuRowView(
                    icon: "doc.text.fill",
                    title: "Terms of Service (TOS)"
                )
            }
            .buttonStyle(.plain)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 8, y: 4)
    }

    private var adjudicatorMenuRow: some View {
        HStack(spacing: 16) {
            Image(systemName: "briefcase.fill")
                .font(.title3)
                .foregroundStyle(Color.accentWalnut)
                .frame(width: 24)

            Text(
                adjReqVM.hasPendingRequest
                    ? "Adjudicator Request (Pending)" : "Apply as Adjudicator"
            )
            .font(.system(.body, design: .default, weight: .medium))
            .foregroundStyle(Color.textCharcoal)

            Spacer()

            if adjReqVM.hasPendingRequest {
                Text("Pending")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color.gray.opacity(0.5))
            }
        }
        .padding()
    }

    private var logoutButton: some View {
        Button(action: { showLogoutAlert = true }) {
            Text("Log Out")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.btnNegative)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
