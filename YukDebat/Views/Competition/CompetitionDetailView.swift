//
//  CompetitionDetailView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct CompetitionDetailView: View {
    let comp: CompetitionModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // 1. JUDUL KOMPETISI (Di atas gambar)
                Text(comp.name)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.textCharcoal)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // 2. POSTER GAMBAR
                RemoteImageView(source: comp.posterStorageUrl)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    .padding(.horizontal, 24)

                // 3. DETAIL INFORMASI
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color.accentWalnut)
                        Text(
                            comp.eventDate.formatted(
                                date: .long,
                                time: .omitted
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    Text(comp.description)
                        .font(.body)
                        .foregroundStyle(Color.textCharcoal)
                        .lineSpacing(6)

                    if !comp.registrationUrl.isEmpty,
                        let url = URL(string: comp.registrationUrl)
                    {
                        Link(destination: url) {
                            Text("Register Here")
                                .font(.headline.bold())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.btnPositive)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
            }
        }
        .background(Color.bgCream.ignoresSafeArea())
        // Perubahan di sini:
        .navigationTitle("Competition Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CompetitionDetailView(
        comp: CompetitionModel(
            id: "1",
            promoterId: "u1",
            promoterEmail: "test@example.com",
            name: "NUDC 2026",
            description:
                "National University Debating Championship - Grand Final Surabaya",
            eventDate: Date(),
            registrationUrl: "https://apple.com",
            posterStorageUrl: "",
            status: .active
        )
    )
}
