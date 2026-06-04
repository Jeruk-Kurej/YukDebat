//
//  AuthToggleModeView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

import SwiftUI

/// Button to switch between Login and Register modes.
struct AuthModeToggleView: View {
    @Binding var isLoginMode: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoginMode.toggle()
            }
        }) {
            Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Log In")
                .font(.subheadline)
                .foregroundStyle(Color.accentWalnut)
        }
        .padding(.top, 8)
    }
}

#Preview {
    AuthModeToggleView(isLoginMode: .constant(true))
}
