//
//  MainView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import SwiftUI

/// The root view that determines whether to show the Authentication flow or the Main Tab Bar.
/// Acts as the main dependency injector for the application's ViewModels.
struct MainView: View {

    // MARK: - Properties

    @EnvironmentObject var authVM: AuthViewModel

    @StateObject private var motionVM = MotionArchiveViewModel(
<<<<<<< HEAD
        apiProxy: CloudFunctionsMock(),
=======
        aiService: GeminiService(),
>>>>>>> main
        localCache: CoreDataStorageMock()
    )

    @StateObject private var sparringVM = SparringViewModel(
        dbService: FirestoreService()
    )

    @StateObject private var evalVM = EvaluationViewModel(
        dbService: FirestoreService()
    )

    // MARK: - Body

    var body: some View {
        Group {
            if authVM.userSession != nil {
                mainTabView
            } else {
                AuthView()
            }
        }
    }

    // MARK: - Sub-Views

    private var mainTabView: some View {
        TabView {
            CompetitionView()
                .tabItem { Label("Competitions", systemImage: "trophy.fill") }

            SparringView(viewModel: sparringVM)
                .tabItem { Label("Sparring", systemImage: "person.2.fill") }

            MotionArchiveView(viewModel: motionVM)
                .tabItem {
                    Label("Motions", systemImage: "books.vertical.fill")
                }

            // Menu Khusus Juri
            if authVM.currentUser?.role == .adjudicator {
                AdjudicatorDashboardView(
                    motionViewModel: motionVM,
                    evalVM: evalVM
                )
                .tabItem { Label("Judge", systemImage: "hammer.fill") }
            }

            // Menu Khusus Admin
            if authVM.currentUser?.role == .admin {
                ModerationDashboardView(
                    viewModel: ModerationDashboardViewModel()
                )
                .tabItem { Label("Admin", systemImage: "shield.checkerboard") }
            }

            // Semua user (termasuk admin/juri) punya akses ke Profile
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Color.btnPositive)
    }
}

// MARK: - Preview

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
