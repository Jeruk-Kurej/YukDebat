//
//  AuthActionButton.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

import SwiftUI

/// Reusable action button for Login/Register.
struct AuthActionButton: View {
    let isLoginMode: Bool
    let isLoading: Bool
    let isValid: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(isLoginMode ? "Log In" : "Register")
                        .font(.headline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isValid ? Color.btnPositive : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading || !isValid)
        .padding(.top, 8)
    }
}

#Preview {
    AuthActionButton(isLoginMode: true, isLoading: false, isValid: true) {}
}
