//
//  AdjudicatorDashboardView.swift
//  YukDebat
//

import SwiftUI

struct AdjudicatorDashboardView: View {
    @ObservedObject var motionViewModel: MotionArchiveViewModel
    @StateObject private var evalVM = EvaluationViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedNote: CaseBuildingNoteModel? = nil
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Adjudicator Tabs", selection: $selectedTab) {
                        Text("Needs Review").tag(0)
                        Text("Review History").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.bgCream)

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            // BUG FIX: Memastikan Tab 0 menampilkan Pending Card
                            if selectedTab == 0 {
                                if evalVM.pendingRequests.isEmpty {
                                    emptyStateView(
                                        icon: "checkmark.seal.fill",
                                        title: "All caught up!",
                                        desc:
                                            "No review requests from debaters at the moment."
                                    )
                                } else {
                                    ForEach(evalVM.pendingRequests) { note in
                                        Button(action: { selectedNote = note })
                                        {
                                            AdjudicatorPendingCard(note: note)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            } else {
                                // BUG FIX: Memastikan Tab 1 menampilkan History Card
                                if evalVM.historyRequests.isEmpty {
                                    emptyStateView(
                                        icon: "clock.fill",
                                        title: "No history yet.",
                                        desc:
                                            "You haven't provided feedback on any notes."
                                    )
                                } else {
                                    ForEach(evalVM.historyRequests) { note in
                                        NavigationLink(
                                            destination: NoteDetailView(
                                                viewModel: motionViewModel,
                                                note: note,
                                                isAdjudicatorContext: true
                                            )
                                        ) {
                                            AdjudicatorHistoryCard(note: note)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationTitle("Adjudicator Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                evalVM.fetchPendingFeedbacks()
                if let juriName = authVM.currentUser?.name {
                    evalVM.fetchEvaluationHistory(providerName: juriName)
                }
            }
            .onChange(of: authVM.currentUser?.name) { newName in
                if let juriName = newName {
                    evalVM.fetchEvaluationHistory(providerName: juriName)
                }
            }
            .sheet(item: $selectedNote) { note in
                ProvideFeedbackSheet(note: note, evalVM: evalVM)
                    .environmentObject(authVM)
            }
        }
    }

    // Sub-view kecil agar kode tetap rapi
    @ViewBuilder
    private func emptyStateView(icon: String, title: String, desc: String)
        -> some View
    {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.purple.opacity(0.5))
            Text(title).font(.title3.bold())
            Text(desc)
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }
}

// MARK: - Mario - Preview
#Preview {
    AdjudicatorDashboardView(
        motionViewModel: MotionArchiveViewModel(
            apiProxy: MockCloudFunctions(),
            localCache: LocalCoreDataStorage()
        )
    )
    .environmentObject(AuthViewModel())
}
