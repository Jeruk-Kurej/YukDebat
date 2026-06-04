//
//  ExploreMotionListView.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 29/05/26.
//

import SwiftUI

struct ExploreMotionListView: View {

    // MARK: - Properties
    @ObservedObject var viewModel: MotionArchiveViewModel
    @EnvironmentObject var authVM: AuthViewModel

    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                Button(action: { viewModel.triggerFetchMotion() }) {
                    HStack(spacing: 8) {
                        if viewModel.isGenerating {
                            ProgressView().tint(.white)
                            Text("Generating Motion...")
                                .font(.subheadline.bold())
                        } else {
                            Image(systemName: "sparkles")
                            Text("Generate Random Motion")
                                .font(.subheadline.bold())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        viewModel.isGenerating
                            ? Color.btnPositive.opacity(0.6) : Color.btnPositive
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.isGenerating)
            }
            .padding([.horizontal, .top])
            .zIndex(1)

            LazyVStack(spacing: 12) {
                if viewModel.isGenerating {
                    MotionSkeletonCard()
                        .padding(.horizontal)
                }

                ForEach(viewModel.filteredMotions) { motion in
                    // Re-calculate isSaved untuk setiap motion setiap kali view di-render ulang
                    // Karena viewModel.myNotes adalah @Published, View akan update otomatis saat list berubah
                    let isSaved = viewModel.myNotes.contains(where: {
                        $0.motionTitle == motion.title
                    })

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "quote.opening")
                                .font(.title2)
                                .foregroundStyle(
                                    Color.accentWalnut.opacity(0.4)
                                )
                            Spacer()
                        }

                        Text(motion.title)
                            .font(.system(.body, design: .serif, weight: .bold))
                            .foregroundStyle(Color.textCharcoal)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 8)

                        Divider().padding(.vertical, 4)

                        if authVM.currentUser?.role != .admin {
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    viewModel.createNoteFromMotion(motion)
                                }
                            }) {
                                HStack {
                                    Image(
                                        systemName: isSaved
                                            ? "checkmark.circle.fill"
                                            : "plus.circle.fill"
                                    )
                                    Text(
                                        isSaved
                                            ? "Saved to Notes" : "Save to Notes"
                                    )
                                }
                                .font(.subheadline.bold())
                                .foregroundStyle(
                                    isSaved ? Color.btnPositive : .white
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    isSaved
                                        ? Color.btnPositive.opacity(0.15)
                                        : Color.btnNeutral
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            // Hapus .disabled(isSaved) agar user bisa tahu statusnya tanpa mengunci tombol (opsional),
                            // atau biarkan kalau kamu mau tetap dikunci setelah save.
                            // Jika ingin bisa di-save ulang setelah hapus, .disabled harus dihilangkan atau diset false saat tidak saved.
                        } else {
                            HStack {
                                Spacer()
                                Text("Admin View (Read Only)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(Color.gray.opacity(0.6))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14).stroke(
                            Color.black.opacity(0.04),
                            lineWidth: 1
                        )
                    )
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 120)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.filteredMotions)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isGenerating)
        }
        .onAppear {
            if let userId = authVM.currentUser?.id {
                viewModel.fetchMyNotes(userId: userId)
            }
        }
    }
}
