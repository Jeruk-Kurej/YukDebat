//
//  ApplyAdjudicatorFormView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import PhotosUI
import SwiftUI

struct ApplyAdjudicatorFormView: View {
    @ObservedObject var viewModel: AdjudicatorRequestViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedItem: PhotosPickerItem? = nil

    private var isFormInvalid: Bool {
        viewModel.experience.isEmpty || viewModel.selectedImageData == nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                Form {
                    Section(
                        header: Text("Certificate / Proof of Competence *")
                            .font(.caption.bold())
                    ) {
                        HStack {
                            Spacer()
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images
                            ) {
                                if let imageData = viewModel.selectedImageData,
                                    let uiImage = UIImage(data: imageData)
                                {
                                    Image(uiImage: uiImage).resizable()
                                        .scaledToFill().frame(height: 200)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 12)
                                        )
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "doc.badge.plus")
                                            .font(.system(size: 40))
                                        Text("Upload Certificate *").font(
                                            .headline
                                        )
                                    }
                                    .foregroundStyle(Color.accentWalnut).frame(
                                        maxWidth: .infinity
                                    ).frame(height: 150)
                                    .background(Color.accentWalnut.opacity(0.1))
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color.accentWalnut,
                                                style: StrokeStyle(
                                                    lineWidth: 2,
                                                    dash: [5]
                                                )
                                            )
                                    )
                                }
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    if let data = try? await newItem?
                                        .loadTransferable(type: Data.self)
                                    {
                                        viewModel.selectedImageData = data
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.white)

                    Section(
                        header: Text("Debate / Adjudicating Experience *").font(
                            .caption.bold()
                        )
                    ) {
                        TextField(
                            "Describe your experience *...",
                            text: $viewModel.experience,
                            axis: .vertical
                        )
                        .frame(minHeight: 100)
                    }
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Apply as Adjudicator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(
                        Color.btnNegative
                    )
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        if let name = authVM.currentUser?.name,
                            let email = authVM.currentUser?.email
                        {
                            viewModel.submitRequest(
                                userName: name,
                                userEmail: email
                            )
                            dismiss()
                        }
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(
                        isFormInvalid || viewModel.isLoading
                            ? Color.gray : Color.btnPositive
                    )
                    .disabled(isFormInvalid || viewModel.isLoading)
                }
            }
        }
    }
}
