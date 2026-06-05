//
//  AdminPendingCardView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 01/06/26.
//

import SwiftUI

struct AdminPendingCardView: View {
    let comp: CompetitionModel
    let onAction: (AdminAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Poster Gambar
            RemoteImageView(source: comp.posterStorageUrl)
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipped()
                .background(Color.gray.opacity(0.1))

            VStack(alignment: .leading, spacing: 8) {
                // Info Judul & Promoter
                Text(comp.name)
                    .font(.headline)
                    .foregroundStyle(Color.textCharcoal)
                    .lineLimit(1)

                Text("By: \(comp.promoterEmail ?? "Unknown")")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Tanggal Kompetisi
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(comp.eventDate.formatted(date: .long, time: .omitted))
                }
                .font(.caption.bold())
                .foregroundStyle(Color.accentWalnut)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.accentWalnut.opacity(0.1))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)

            // Aksi Buttons
            HStack(spacing: 12) {
                Text("Reject")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .background(Color.btnNegative.opacity(0.1))
                    .foregroundStyle(Color.btnNegative)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        print("🔘 AdminPendingCardView: Reject clicked")
                        onAction(.reject)
                    }

                Text("Approve")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .background(Color.btnPositive)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        print("🔘 AdminPendingCardView: Approve clicked")
                        onAction(.approve)
                    }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview
#Preview {
    AdminPendingCardView(
        comp: CompetitionModel(
            id: "1",
            promoterId: "user_1",
            promoterEmail: "test@gmail.com",
            name: "Debate Fest",
            description: "A great debate competition",
            eventDate: Date(),
            registrationUrl: "",
            posterStorageUrl: "",
            status: .pending
        )
    ) { _ in }
}
