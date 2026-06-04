//
//  AuthHeaderView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

import SwiftUI

/// Header component for the Authentication screen.
struct AuthHeaderView: View {
    let isLoginMode: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentWalnut)
            
            Text("YukDebat")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.textCharcoal)
            
            Text(isLoginMode ? "Welcome back, Debater!" : "Join the Arena!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AuthHeaderView(isLoginMode: true)
}
