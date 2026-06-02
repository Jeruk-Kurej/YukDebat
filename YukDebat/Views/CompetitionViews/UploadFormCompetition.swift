//
//  UploadFormCompetition.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import PhotosUI
import SwiftUI
import UIKit

struct UploadFormCompetition: View {
    @ObservedObject var viewModel: CompetitionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedItem: PhotosPickerItem? = nil

    // Cek validasi required field
    private var isFormInvalid: Bool {
        viewModel.name.isEmpty || viewModel.registrationUrl.isEmpty
            || viewModel.selectedImageData == nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgCream.ignoresSafeArea()
                Form {
                    // Poster bersertifikat/Lomba dianggap Required (*)
                    Section(
                        header: Text("Competition Poster *").font(
                            .caption.bold()
                        )
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
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 40))
                                        Text("Select Poster *").font(.headline)
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
                        header: Text("Competition Details").font(
                            .caption.bold()
                        )
                    ) {
                        TextField("Competition Name *", text: $viewModel.name)
                        DatePicker(
                            "Event Date *",
                            selection: $viewModel.eventDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        TextField(
                            "Registration Link (URL) *",
                            text: $viewModel.registrationUrl
                        )
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)

                        // Deskripsi bersifat Opsional -> Biarkan polos tanpa tanda tambahan
                        TextField(
                            "Description / Registration Info",
                            text: $viewModel.desc,
                            axis: .vertical
                        )
                        .frame(minHeight: 80)
                    }
                    .listRowBackground(Color.white)

                    Button(action: {
                        viewModel.submitCompetitionData()
                    }) {
                        Text("Create Competition")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    // KONSISTENSI BUTTON: Jika required kosong, langsung ke grey out dan disable secara total
                    .disabled(isFormInvalid || viewModel.isLoading)
                    .listRowBackground(
                        isFormInvalid || viewModel.isLoading
                            ? Color.gray : Color.btnPositive
                    )
                }
                .scrollContentBackground(.hidden)

                if viewModel.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView().scaleEffect(1.5).tint(.white)
                        Text("Uploading...").font(.headline).foregroundStyle(
                            .white
                        )
                    }
                    .padding(32).background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                }
            }
            .navigationTitle("Add Competition")
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
