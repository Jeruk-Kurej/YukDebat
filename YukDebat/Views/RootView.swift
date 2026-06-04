//
//  RootView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 13/05/26.
//

import SwiftUI

/// The root view orchestrating authentication state and routing.
struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.userSession != nil {
                if authVM.isLoading && authVM.currentUser == nil {
                    ZStack {
                        Color.bgCream.ignoresSafeArea()
                        ProgressView("Memuat Data Pengguna...")
                    }
                } else {
                    MainView()
                }
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}
