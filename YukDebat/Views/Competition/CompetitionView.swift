//
//  CompetitionView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import SwiftUI

struct CompetitionView: View {
    @StateObject private var viewModel = CompetitionViewModel()
    @State private var showUploadForm = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()

                // REVISI: Logika jika 100% kosong, taruh teks di tengah
                if viewModel.activeCompetitions.isEmpty && viewModel.myPendingCompetitions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray.opacity(0.4))
                        Text("No Competition")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 60)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            if !viewModel.myPendingCompetitions.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Pending Admin Approval").font(.headline).foregroundStyle(Color.textCharcoal).padding(.horizontal, 24)
                                    ForEach(viewModel.myPendingCompetitions) { comp in
                                        CompetitionCard(comp: comp, isPending: true)
                                    }
                                }
                            }

                            if !viewModel.activeCompetitions.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Latest Competitions").font(.headline).foregroundStyle(Color.textCharcoal).padding(.horizontal, 24)
                                    ForEach(viewModel.activeCompetitions) { comp in
                                        CompetitionCard(comp: comp, isPending: false)
                                    }
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }

                Button(action: { showUploadForm = true }) {
                    Image(systemName: "plus").font(.title2.bold()).foregroundStyle(.white).frame(width: 60, height: 60)
                        .background(Color.btnPositive).clipShape(Circle()).shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 24).padding(.bottom, 110)
            }
            .navigationTitle("Competitions")
            .onAppear { viewModel.fetchCompetitions() }
            .sheet(isPresented: $showUploadForm) { UploadFormCompetition(viewModel: viewModel) }
            .modernToast(message: $viewModel.statusMessage, isError: viewModel.statusMessage?.contains("Failed") == true)
        }
    }
}

// MARK: - Preview
#Preview {
    CompetitionView()
}
