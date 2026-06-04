//
//  AdminAdjudicatorHistoryRowView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct AdminAdjudicatorHistoryRowView: View {
    let req: AdjudicatorRequestModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(req.fullName).font(.headline)
                Text(req.userEmail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.btnPositive)
        }
        .padding(16).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
}
