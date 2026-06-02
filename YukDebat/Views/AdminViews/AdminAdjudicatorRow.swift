//
//  AdminAdjudicatorRow.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

/// A read-only row displaying a previously approved adjudicator application.
struct AdminAdjudicatorRow: View {
    let req: AdjudicatorRequestModel
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "briefcase.fill").foregroundStyle(.purple)
                VStack(alignment: .leading) {
                    Text(req.fullName).font(.subheadline.bold())
                    Text(req.userEmail).font(.caption).foregroundStyle(
                        .secondary
                    )
                }
            }
            .padding(.horizontal, 16).padding(.top, 16)

            RemoteImageView(source: req.certificateUrl)
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()
                .padding(.horizontal, 16)

            Text(req.experience)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            HStack(spacing: 12) {
                Button(action: onReject) {
                    Text("Reject")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.btnNegative.opacity(0.1))
                        .foregroundStyle(Color.btnNegative)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button(action: onApprove) {
                    Text("Approve")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.btnPositive)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(16)
        }
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                Color.black.opacity(0.05),
                lineWidth: 1
            )
        )
        .padding(.horizontal, 20)
    }
}
