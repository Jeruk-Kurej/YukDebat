import SwiftUI

struct MotionArchiveView: View {
    @ObservedObject var viewModel: MotionArchiveViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedTab = 0
    @State private var showingNewNoteSheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    if authVM.currentUser?.role != .admin {
                        Picker("Navigation Menu", selection: $selectedTab) {
                            Text("Explore").tag(0)
                            Text("My Notes").tag(1)
                            Text("Community").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                    }

                    // KONDISI JIKA SEDANG GENERATE: Selalu munculkan skeleton di tab Explore / Admin paling atas
                    if viewModel.isGenerating
                        && (selectedTab == 0
                            || authVM.currentUser?.role == .admin)
                    {
                        MotionSkeletonCard()
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }

                    if authVM.currentUser?.role == .admin {
                        ExploreMotionListView(viewModel: viewModel)
                    } else {
                        if selectedTab == 0 {
                            ExploreMotionListView(viewModel: viewModel)
                        } else if selectedTab == 1 {
                            MyNotesListView(viewModel: viewModel)
                        } else {
                            CommunityNotesView(viewModel: viewModel)
                        }
                    }
                }

                // Tampilan FAB untuk My Notes
                if selectedTab == 1 && authVM.currentUser?.role != .admin {
                    Button(action: { showingNewNoteSheet = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.btnPositive)
                            .clipShape(Circle())
                            .shadow(
                                color: Color.black.opacity(0.15),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 110)
                }

                // POP-UP TOAST OVERLAY JIKA TERJADI HIGH DEMAND (503)
                if viewModel.showHighDemandToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.white)
                            Text(viewModel.toastMessage)
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 6)
                        .padding(.bottom, 120)
                        .padding(.horizontal, 24)
                        .onAppear {
                            // Toast otomatis hilang setelah 4 detik
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4)
                            {
                                viewModel.showHighDemandToast = false
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle(
                authVM.currentUser?.role == .admin
                    ? "Motions List" : "Motion Archive"
            )
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search motions..."
            )
            .sheet(isPresented: $showingNewNoteSheet) {
                NavigationStack {
                    NoteEditorView(
                        viewModel: viewModel,
                        draftNote: CaseBuildingNoteModel(
                            id: UUID().uuidString,
                            ownerId: authVM.currentUser?.id ?? "user_me",
                            motionTitle: "",
                            argumentsRichText: "",
                            visibility: .privateAccess,
                            isFeedbackRequested: false,
                            updatedAt: Date()
                        ),
                        isNewNote: true
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MotionArchiveView(
        viewModel: MotionArchiveViewModel(
            apiProxy: MockCloudFunctions(),
            localCache: LocalCoreDataStorage()
        )
    )
    .environmentObject(AuthViewModel())
}
