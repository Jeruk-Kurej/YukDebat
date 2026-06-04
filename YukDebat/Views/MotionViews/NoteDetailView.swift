//
//  NoteDetailView.swift
//  YukDebat
//


import SwiftUI

struct NoteDetailView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: MotionArchiveViewModel
    let note: CaseBuildingNoteModel
    var isAdjudicatorContext: Bool = false
    @EnvironmentObject var authVM: AuthViewModel

    @State private var showingNoteEditSheet = false
    @State private var showingFeedbackEditSheet = false

    // MARK: - Computed Properties
    var latestNote: CaseBuildingNoteModel {
        viewModel.myNotes.first { $0.id == note.id } ?? viewModel.communityNotes
            .first { $0.id == note.id } ?? note
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.bgCream.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerView
                    Divider()
                    contentView
                    Divider().padding(.vertical, 8)
                    feedbackView
                }
                .padding(24)
            }
        }
        .navigationTitle(
            isAdjudicatorContext ? "Review Details" : "Note Details"
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // BUG FIX: Gunakan .topBarTrailing agar styling-nya murni teks (konsisten)!
            if isAdjudicatorContext {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit Feedback") { showingFeedbackEditSheet = true }
                        .fontWeight(.bold)
                        .foregroundStyle(.purple)
                }
            } else if latestNote.ownerId == authVM.currentUser?.id {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit Note") { showingNoteEditSheet = true }
                        .fontWeight(.bold)
                        .foregroundStyle(Color.btnPositive)
                }
            }
        }
        .sheet(isPresented: $showingNoteEditSheet) {
            NavigationStack {
                NoteEditorView(
                    viewModel: viewModel,
                    draftNote: latestNote,
                    isNewNote: false
                )
            }
        }
        .sheet(isPresented: $showingFeedbackEditSheet) {
            ProvideFeedbackSheetView(
                note: latestNote,
                evalVM: EvaluationViewModel(dbService: FirestoreService())
            )
            .environmentObject(authVM)
        }
    }

    // MARK: - Sub-Views

    @ViewBuilder
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(
                    systemName: latestNote.visibility == .publicAccess
                        ? "globe" : "lock.fill"
                )
                Text(
                    latestNote.visibility == .publicAccess
                        ? "Public Access" : "Private Access"
                )
            }
            .font(.caption.bold())
            .foregroundStyle(
                latestNote.visibility == .publicAccess
                    ? Color.btnPositive : Color.btnNegative
            )
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(
                latestNote.visibility == .publicAccess
                    ? Color.btnPositive.opacity(0.1)
                    : Color.btnNegative.opacity(0.1)
            )
            .clipShape(Capsule())

            Text(latestNote.motionTitle)
                .font(.title2.bold())
                .foregroundStyle(Color.textCharcoal)
                .padding(.top, 4)

            Text(
                "Last modified: \(latestNote.updatedAt.formatted(date: .abbreviated, time: .shortened))"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Case Building Note").font(.headline).foregroundStyle(
                Color.accentWalnut
            )
            if latestNote.argumentsRichText.isEmpty {
                Text("No arguments or notes written yet.")
                    .font(.body).foregroundStyle(.gray.opacity(0.8)).italic()
                    .padding(.top, 8)
            } else {
                Text(latestNote.argumentsRichText)
                    .font(.body).foregroundStyle(Color.textCharcoal)
                    .lineSpacing(4)
            }
        }
    }

    @ViewBuilder
    private var feedbackView: some View {
        if let feedback = latestNote.feedbackText, !feedback.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "star.bubble.fill")
                    Text(
                        "Feedback from: \(latestNote.feedbackProviderName ?? "Adjudicator")"
                    )
                }
                .font(.headline).foregroundStyle(.purple)

                Text(feedback)
                    .font(.body).foregroundStyle(Color.textCharcoal).padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.1)).clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
            }
        } else if latestNote.visibility == .publicAccess {
            if !isAdjudicatorContext {
                Button(action: {
                    withAnimation {
                        viewModel.requestFeedback(for: latestNote.id)
                    }
                }) {
                    HStack {
                        Text(
                            latestNote.isFeedbackRequested
                                ? "Waiting for Adjudicator Feedback..."
                                : "Request Adjudicator Feedback"
                        )
                    }
                    .font(.headline).foregroundStyle(.white).frame(
                        maxWidth: .infinity
                    ).padding()
                    .background(
                        latestNote.isFeedbackRequested
                            ? Color.gray : Color.purple
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(latestNote.isFeedbackRequested)
            }
        }
    }
}

#Preview {
    NoteDetailView(
        viewModel: MotionArchiveViewModel(
            aiService: GeminiServiceMock(),
            localCache: CoreDataStorageMock()
        ),
        note: CaseBuildingNoteModel(
            id: "1",
            ownerId: "owner",
            motionTitle: "Sample Motion",
            argumentsRichText: "Sample arguments",
            visibility: .publicAccess,
            isFeedbackRequested: false,
            updatedAt: Date()
        )
    )
    .environmentObject(AuthViewModel())
}
