//
//  EditProfileView.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 02/06/26.
//

import SwiftUI

/// Form for users to edit their personal information (currently limited to Name).
struct EditProfileView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var newName: String = ""
    @State private var isUpdating = false
    @State private var errorMessage: String = ""
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section(
                header: Text("Personal Information").font(.caption),
                footer: Text("For now, you can only change your display name. Email changes require administrative approval.")
            ) {
                TextField("Full Name", text: $newName)
                    .textContentType(.name)
                    .autocorrectionDisabled()
            }
            .listRowBackground(Color.white)
            
            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Color.btnNegative)
                }
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.bgCream.ignoresSafeArea())
        .navigationTitle("Edit Account")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            newName = authVM.currentUser?.name ?? ""
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveNameChange()
                }
                .fontWeight(.bold)
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty || isUpdating)
            }
        }
    }
    
    // MARK: - Methods
    
    private func saveNameChange() {
        let trimmedName = newName.trimmingCharacters(in: .whitespaces)
        
        isUpdating = true
        errorMessage = ""
        
        authVM.updateName(newName: trimmedName) { error in
            isUpdating = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                dismiss()
            }
        }
    }
}
