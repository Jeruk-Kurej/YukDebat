//
//  AuthView.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 01/06/26.
//

// MARK: - Auth - View

import SwiftUI

/// Main container for Authentication. Handles the switching between Login and Registration states.
struct AuthView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var isLoginMode: Bool = true
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        AuthHeaderView(isLoginMode: isLoginMode)
                            .padding(.top, 60)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 16) {
                            if !isLoginMode {
                                AuthInputFieldView(title: "Full Name", text: $fullName)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            AuthInputFieldView(title: "Email Address", text: $email, isSecure: false)
                                .keyboardType(.emailAddress)
                            
                            AuthInputFieldView(title: "Password", text: $password, isSecure: true)
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isLoginMode)
                        
                        AuthActionButtonView(
                            isLoginMode: isLoginMode,
                            isLoading: authVM.isLoading,
                            isValid: isValidForm
                        ) {
                            handleAction()
                        }
                        
                        AuthModeToggleView(isLoginMode: $isLoginMode)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle(isLoginMode ? "Login" : "Register")
            .navigationBarTitleDisplayMode(.inline)
            .modernToast(message: $authVM.errorMessage, isError: true)
        }
    }
    
    // MARK: - Private Logic
    
    private var isValidForm: Bool {
        isLoginMode ? (!email.isEmpty && !password.isEmpty) : (!email.isEmpty && !password.isEmpty && !fullName.isEmpty)
    }
    
    private func handleAction() {
        if isLoginMode {
            authVM.login(email: email, password: password)
        } else {
            authVM.register(email: email, password: password, fullName: fullName)
        }
    }
}

#Preview {
    AuthView().environmentObject(AuthViewModel())
}
