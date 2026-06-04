//
//  AdminHistoryRowView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 01/06/26.
//

import SwiftUI

/// A read-only row displaying a previously approved competition.
struct AdminHistoryRowView: View {

    // MARK: - Properties

    let comp: CompetitionModel

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {

            // IMPLEMENTASI BARU:
            // Cukup panggil RemoteImageView 1 baris.
            // Komponen ini akan otomatis mengurus URL Cloudinary atau Base64 lama!
            RemoteImageView(source: comp.posterStorageUrl)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(comp.name)
                    .font(.headline)
                    .foregroundStyle(Color.textCharcoal)
                    .lineLimit(1)

                Text(comp.promoterEmail ?? "User")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.title2)
                .foregroundStyle(Color.btnPositive)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    AdminHistoryRowView(
        comp: CompetitionModel(
            id: "1",
            promoterId: "u1",
            promoterEmail: "promoter@yukdebat.com",
            name: "East Java Varsity English Debate",
            description: "An annual debate competition.",
            eventDate: Date(),
            registrationUrl: "https://example.com",
            posterStorageUrl: "",
            status: .active
        )
    )
}
