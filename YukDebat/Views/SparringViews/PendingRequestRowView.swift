//
//  PendingRequestRowView.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

import SwiftUI

struct PendingRequestRowView: View {
    let participant: ParticipantModel
    let onReject: () -> Void
    let onApprove: () -> Void
    
    var body: some View {
        HStack {
            Text(participant.userName).font(.subheadline.bold())
            Spacer()
            Button(action: onReject) {
                Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(Color.btnNegative)
            }.buttonStyle(.plain)
            
            Button(action: onApprove) {
                Image(systemName: "checkmark.circle.fill").font(.title2).foregroundStyle(Color.btnPositive)
            }.buttonStyle(.plain).padding(.leading, 8)
        }
    }
}
