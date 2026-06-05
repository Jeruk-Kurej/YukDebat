//
//  SparringParticipantRowView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct SparringParticipantRowView: View {
    let participant: ParticipantModel
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.accentWalnut)

            VStack(alignment: .leading) {
                Text(
                    isCurrentUser
                        ? "You (\(participant.userName))" : participant.userName
                )
                .font(.subheadline.bold())
                Text("Debater")  // placeholder email jika belum ada
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            let modeText = participant.regMode == .team ? "Team (2 Slots)" : "Solo (1 Slot)"
            Text(modeText)
                .font(.caption2.bold())
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.accentWalnut.opacity(0.1))
                .foregroundStyle(Color.accentWalnut)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}
