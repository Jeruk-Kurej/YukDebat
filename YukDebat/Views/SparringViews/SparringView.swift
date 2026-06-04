//
//  SparringView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import Combine
import SwiftUI

struct SparringView: View {
    @ObservedObject var viewModel: SparringViewModel
    @EnvironmentObject var authVM: AuthViewModel

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.bgCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        if viewModel.lobbyRooms.isEmpty {
                            Text("No sparring rooms available.")
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(
                                    Color.textCharcoal.opacity(0.6)
                                )
                                .multilineTextAlignment(.center)
                                .padding(.top, 60)
                        }

                        ForEach(viewModel.lobbyRooms) { room in
                            SparringRoomCardView(
                                room: room,
                                viewModel: viewModel
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }

                // 2. Wrap tombol ini dengan pengecekan role
                // Admin tidak bisa membuat sparring lobby
                if authVM.currentUser?.role != .admin {
                    Button(action: { viewModel.isShowingCreateRoom = true }) {
                        Image(systemName: "plus")
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
            }
            .navigationTitle("Sparring Lobby")
            .onAppear {
                viewModel.listenToRooms()
                viewModel.checkAndCancelExpiredRooms()
                viewModel.cleanupOldRooms()
            }
            .onReceive(timer) { _ in
                withAnimation {
                    viewModel.checkAndCancelExpiredRooms()
                }
            }
            .sheet(isPresented: $viewModel.isShowingCreateRoom) {
                CreateSparringFormView(viewModel: viewModel)
            }
            .modernToast(message: $viewModel.errorMessage, isError: true)
            .modernToast(message: $viewModel.alertMessage, isError: false)
        }
    }
}
