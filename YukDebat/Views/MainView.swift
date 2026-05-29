//
//  MainView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            CompetitionView()
                .tabItem {
                    Label("Competition", systemImage: "trophy.fill")
                }
            
            SparringView(viewModel: SparringViewModel(dbService: MockFirestoreService()))
                .tabItem {
                    Label("Sparring", systemImage: "person.2.fill")
                }
            
            MotionArchiveTabView()
                .tabItem {
                    Label("Motions", systemImage: "books.vertical.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(Color.btnPositive)
    }
}

// Placeholder (Profile)
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.accentWalnut)
                    Text("Settings & Profile")
                        .font(.headline)
                    Text("Manajemen akun, ganti role sementara, dan tombol Log Out.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainView()
}
