//
//  MainView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import SwiftUI

struct MainView: View {
    // Inisialisasi ViewModel secara Global untuk menahan state
    @StateObject private var motionViewModel = MotionArchiveViewModel(
        apiProxy: MockCloudFunctions(),
        localCache: LocalCoreDataStorage()
    )

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            SparringView()
                .tabItem { Label("Sparring", systemImage: "figure.boxing") }

            // Motion Archive dipassing ViewModel yang sama agar data sinkron
            MotionArchiveView(viewModel: motionViewModel)
                .tabItem {
                    Label("Motions", systemImage: "books.vertical.fill")
                }

            // Tab Dashboard Juri (UC04)
            AdjudicatorDashboardView(motionViewModel: motionViewModel)
                .tabItem { Label("Juri", systemImage: "briefcase.fill") }

            // Tab Profil
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Color.btnPositive)  // Warna icon tab saat aktif
    }
}

#Preview {
    MainView()
}
