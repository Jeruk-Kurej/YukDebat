//
//  CompetitionCardView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import SwiftUI

/// A card displaying a competition's poster, name, and current status.
struct CompetitionCardView: View {

    // MARK: - Properties

    let comp: CompetitionModel
    let isPending: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // 1. HERO IMAGE
            RemoteImageView(source: comp.posterStorageUrl)
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(alignment: .topTrailing) {
                    if isPending {
                        badgeView(text: "PENDING", color: .orange)
                            .padding(16)
                    }
                }

            // 2. CARD CONTENT
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(comp.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.textCharcoal)
                        .lineLimit(2)
                    
                    Text(comp.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    Label {
                        Text(formatDate(comp.eventDate))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    @ViewBuilder
    private func badgeView(text: String, color: Color) -> some View {
        Text(text.uppercased())
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .environment(\.colorScheme, .dark)
    }
}

// MARK: - Preview
#Preview {
//    CompetitionCardView(
//        comp: CompetitionModel(
//            id: "1",
//            promoterId: "user_1",
//            promoterEmail: "test@example.com",
//            name: "NUDC 2026",
//            description: "National University Debating Championship",
//            eventDate: Date(),
//            registrationUrl: "",
//            posterStorageUrl: "",
//            status: .active
//        ),
//        isPending: false
//    )
}
