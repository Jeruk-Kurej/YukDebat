//
//  NoteModerationRowView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct NoteModerationRowView: View {
    let note: CaseBuildingNoteModel
    let onHide: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(note.motionTitle).font(.headline).lineLimit(1)
                Text("ID: \(note.id)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onHide) {
                Image(systemName: "eye.slash.fill").foregroundStyle(Color.btnNegative)
            }
        }
        .padding(16).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
}

#Preview {
    NoteModerationRowView(note: CaseBuildingNoteModel(id: "1", ownerId: "owner", motionTitle: "Sample Motion", argumentsRichText: "Sample text", visibility: .publicAccess, isFeedbackRequested: false, updatedAt: Date())) {}
}
