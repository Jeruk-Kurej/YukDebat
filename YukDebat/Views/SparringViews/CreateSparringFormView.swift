//
//  CreateSparringFormView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

/// Form to create a new sparring room with input validation.
struct CreateSparringFormView: View {
    @ObservedObject var viewModel: SparringViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Motion & Schedule Details").font(.caption.bold())) {
                    TextField("Ketik Judul/Topik Mosi *", text: $viewModel.formMotionTitle, axis: .vertical)
                        .lineLimit(2...4)

                    DatePicker("Scheduled Time *", selection: $viewModel.formScheduledTime, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "id_ID"))
                }
                .listRowBackground(Color.white)

                Section(header: Text("Meeting Information").font(.caption.bold())) {
                    TextField("Zoom/Google Meet Link *", text: $viewModel.formMeetingLink)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)

                    TextField("Additional Notes", text: $viewModel.formSpecialNotes)

                    Toggle("Make Room Private", isOn: $viewModel.isFormPrivate)
                        .tint(Color.btnPositive)
                }
                .listRowBackground(Color.white)
                
                // Submit Button Section
                Section {
                    SparringSubmitButtonView(
                        isEnabled: !isFormInvalid,
                        action: {
                            viewModel.submitRoomForm()
                            dismiss()
                        }
                    )
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color.bgCream)
            .navigationTitle("Create New Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.btnNegative)
                }
            }
        }
    }

    private var isFormInvalid: Bool {
        viewModel.formMotionTitle.isEmpty || viewModel.formMeetingLink.isEmpty
    }
}

#Preview {
    CreateSparringFormView(viewModel: SparringViewModel(dbService: FirestoreServiceMock()))
}
