//
//  ProvideFeedbackSheet.swift
//  YukDebat
//

import SwiftUI

/// A bottom sheet form for Adjudicators to write and submit feedback.
struct ProvideFeedbackSheet: View {
    // MARK: - Properties
    let note: CaseBuildingNoteModel
    @ObservedObject var evalVM: EvaluationViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var feedbackText: String
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    // MARK: - Initialization (BUG FIX FORM KOSONG)
    init(note: CaseBuildingNoteModel, evalVM: EvaluationViewModel) {
        self.note = note
        self.evalVM = evalVM
        // Paksa state terisi sejak awal sebelum View dirender
        _feedbackText = State(initialValue: note.feedbackText ?? "")
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                Form {
                    Section(
                        header: Text("Debater Note Details").font(
                            .caption.bold()
                        )
                    ) {
                        Text(note.motionTitle).font(.headline).foregroundStyle(
                            Color.textCharcoal
                        )
                        Text(note.argumentsRichText).font(.body)
                            .foregroundStyle(.secondary).padding(.vertical, 4)
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text("Provide Feedback (Required)").font(
                            .caption.bold()
                        )
                    ) {
                        TextEditor(text: $feedbackText)
                            .frame(minHeight: 150)
                    }
                    .listRowBackground(Color.white)

                    if let error = errorMessage {
                        Section {
                            Text(error).font(.caption).foregroundStyle(
                                Color.btnNegative
                            )
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(
                note.feedbackText == nil ? "Evaluate Note" : "Edit Feedback"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(
                        Color.btnNegative
                    )
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: submitAction) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit").fontWeight(.bold)
                        }
                    }
                    .foregroundStyle(
                        feedbackText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty || isSubmitting ? Color.gray : Color.purple
                    )
                    .disabled(
                        feedbackText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty || isSubmitting
                    )
                }
            }
        }
    }

    // MARK: - Logic
    private func submitAction() {
        isSubmitting = true
        errorMessage = nil
        let juriName = authVM.currentUser?.name ?? "Anonymous Adjudicator"

        evalVM.submitFeedback(
            noteId: note.id,
            feedbackText: feedbackText,
            providerName: juriName
        ) { success, error in
            isSubmitting = false
            if success {
                dismiss()
            } else {
                errorMessage = error ?? "Failed to save feedback."
            }
        }
    }
}
