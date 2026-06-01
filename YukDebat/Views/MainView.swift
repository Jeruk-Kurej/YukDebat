//
//  MainView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import SwiftUI

/// The root view that determines whether to show the Authentication flow or the Main Tab Bar.
struct MainView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var motionVM = MotionArchiveViewModel(apiProxy: MockCloudFunctions(), localCache: LocalCoreDataStorage())
    @StateObject private var sparringVM = SparringViewModel(dbService: MockFirestoreService())
    
    var body: some View {
        if authVM.userSession != nil {
            TabView {
                CompetitionView()
                    .tabItem { Label("Competitions", systemImage: "trophy.fill") }
                
                SparringView(viewModel: sparringVM)
                    .tabItem { Label("Sparring", systemImage: "figure.fencing") }
                
                MotionArchiveView(viewModel: motionVM)
                    .tabItem { Label("Motions", systemImage: "books.vertical.fill") }
                
                // REVISI: Menu Khusus Juri
                if authVM.currentUser?.role == .adjudicator {
                    AdjudicatorDashboardView(motionViewModel: motionVM)
                        .tabItem { Label("Judge", systemImage: "gavel") }
                }
                
                // REVISI: Menu Khusus Admin
                if authVM.currentUser?.role == .admin {
                    ModerationDashboardView(viewModel: ModerationDashboardViewModel())
                        .tabItem { Label("Admin", systemImage: "shield.checkerboard") }
                }
                
                // REVISI: Semua user (termasuk admin/juri) punya akses ke Profile
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.fill") }
            }
            .tint(Color.btnPositive)
        } else {
            AuthView()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
