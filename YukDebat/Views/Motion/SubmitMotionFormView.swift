//
//  SubmitMotionFormView.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 01/06/26.
//

import SwiftUI

struct SubmitMotionFormView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    
    private var isFormValid: Bool { !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                Form {
                    Section(header: Text("Motion Suggestion Details").font(.caption.bold())) {
                        TextField("Enter your custom motion title...", text: $title, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Suggest Motion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Color.btnNegative)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        viewModel.submitCustomMotion(title: title)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(isFormValid ? Color.btnPositive : Color.gray)
                    .disabled(!isFormValid || viewModel.isLoading)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SubmitMotionFormView(
        viewModel: MotionArchiveViewModel(
            apiProxy: MockCloudFunctions(),
            localCache: LocalCoreDataStorage()
        )
    )
}
