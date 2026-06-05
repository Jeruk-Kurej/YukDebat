//
//  PendingRequestRowView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct PendingRequestRowView: View {
    let participant: ParticipantModel
    let onReject: () -> Void
    let onApprove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(participant.userName).font(.subheadline.bold())
                if let email = participant.userEmail, !email.isEmpty {
                    Text(email).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            
            let modeText = participant.regMode == .team ? "Team (2 Slots)" : "Solo (1 Slot)"
            Text(modeText)
                .font(.caption2.bold())
                .padding(.horizontal, 6).padding(.vertical, 3)
                .background(Color.orange.opacity(0.1))
                .foregroundStyle(Color.orange)
                .clipShape(Capsule())
                .padding(.trailing, 4)

            Button(action: onReject) {
                Image(systemName: "xmark.circle.fill").font(.title2)
                    .foregroundStyle(Color.btnNegative)
            }.buttonStyle(.plain)

            Button(action: onApprove) {
                Image(systemName: "checkmark.circle.fill").font(.title2)
                    .foregroundStyle(Color.btnPositive)
            }.buttonStyle(.plain).padding(.leading, 8)
        }
    }
}
