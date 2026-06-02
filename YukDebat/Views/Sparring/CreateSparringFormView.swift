//
//  CreateSparringFormView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct CreateSparringFormView: View {
    @ObservedObject var viewModel: SparringViewModel
    @Environment(\.dismiss) var dismiss

    // Validasi form required field
    private var isFormInvalid: Bool {
        viewModel.formMotionTitle.isEmpty || viewModel.formMeetingLink.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                Form {
                    Section(
                        header: Text("Motion & Schedule Details").font(
                            .caption.bold()
                        )
                    ) {
                        TextField(
                            "Ketik Judul/Topik Mosi *",
                            text: $viewModel.formMotionTitle,
                            axis: .vertical
                        )
                        .lineLimit(2...4)

                        DatePicker(
                            "Scheduled Time *",
                            selection: $viewModel.formScheduledTime,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "id_ID"))
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text("Meeting Information").font(
                            .caption.bold()
                        )
                    ) {
                        TextField(
                            "Zoom/Google Meet Link *",
                            text: $viewModel.formMeetingLink
                        )
                        .keyboardType(.URL).textInputAutocapitalization(.never)

                        // Additional Notes bersifat opsional -> Bersihkan teks kata (Optional)
                        TextField(
                            "Additional Notes",
                            text: $viewModel.formSpecialNotes
                        )

                        Toggle(
                            "Make Room Private",
                            isOn: $viewModel.formIsPrivate
                        ).tint(Color.btnPositive)
                    }
                    .listRowBackground(Color.white)

                    Button(action: {
                        viewModel.submitRoomForm()
                    }) {
                        Text("Create Sparring Room")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    // KONSISTENSI BUTTON: Jika required kosong, auto grey out & disabled
                    .disabled(isFormInvalid)
                    .listRowBackground(
                        isFormInvalid ? Color.gray : Color.btnPositive
                    )
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Create New Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(
                        Color.btnNegative
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CreateSparringFormView(
        viewModel: SparringViewModel(dbService: MockFirestoreService())
    )
}
