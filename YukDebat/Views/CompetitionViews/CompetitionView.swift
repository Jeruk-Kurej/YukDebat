//
//  CompetitionView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import SwiftUI

struct CompetitionView: View {

    // MARK: - Properties
    
    // FIX: Masukkan CloudinaryService sebagai dependency injection
    @StateObject private var viewModel = CompetitionViewModel(storageService: CloudinaryService())
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var showUploadForm = false

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()

                if viewModel.activeCompetitions.isEmpty && viewModel.myPendingCompetitions.isEmpty {
                    emptyStateView
                } else {
                    contentScrollView
                }

                // FAB (Floating Action Button) hanya untuk non-admin
                if authVM.currentUser?.role != .admin {
                    fabButton
                }
            }
            .navigationTitle("Competitions")
            .onAppear { viewModel.fetchCompetitions() }
            .sheet(isPresented: $showUploadForm) {
<<<<<<< HEAD
                UploadFormCompetition(viewModel: viewModel)
=======
                UploadCompetitionFormView(viewModel: viewModel)
>>>>>>> main
            }
            .modernToast(
                message: $viewModel.statusMessage,
                isError: viewModel.hasError
            )
        }
    }
    
    // MARK: - Sub-Views
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.4))
            Text("No Competitions Yet")
                .font(.title3.bold())
                .foregroundStyle(Color.textCharcoal)
            Text("Stay tuned for upcoming debate tournaments.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }
    
    private var contentScrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if !viewModel.myPendingCompetitions.isEmpty {
                    pendingSection
                }

                if !viewModel.activeCompetitions.isEmpty {
                    activeSection
                }
            }
            .padding(.bottom, 120)
        }
    }
    
    private var pendingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Pending Admin Approval")
                .font(.headline)
                .foregroundStyle(Color.textCharcoal)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            ForEach(viewModel.myPendingCompetitions) { comp in
<<<<<<< HEAD
                CompetitionCard(comp: comp, isPending: true)
=======
                CompetitionCardView(comp: comp, isPending: true)
>>>>>>> main
            }
        }
    }
    
    private var activeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Latest Competitions")
                .font(.headline)
                .foregroundStyle(Color.textCharcoal)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            ForEach(viewModel.activeCompetitions) { comp in
                NavigationLink(destination: CompetitionDetailView(comp: comp)) {
<<<<<<< HEAD
                    CompetitionCard(comp: comp, isPending: false)
=======
                    CompetitionCardView(comp: comp, isPending: false)
>>>>>>> main
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var fabButton: some View {
        Button(action: { showUploadForm = true }) {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color.btnPositive)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 110)
    }
}

// MARK: - Preview

#Preview {
    CompetitionView()
        .environmentObject(AuthViewModel())
}
