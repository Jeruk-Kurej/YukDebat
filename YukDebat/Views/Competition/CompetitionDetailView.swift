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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RemoteImageView(source: comp.posterStorageUrl)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(comp.name).font(.title.bold())

                HStack {
                    Image(systemName: "calendar")
                    Text(comp.eventDate.formatted(date: .long, time: .omitted))
                }.foregroundStyle(.secondary)

                Text(comp.description)
                    .font(.body)
                    .lineSpacing(4)

                if !comp.registrationUrl.isEmpty {
                    Link(
                        "Register Here",
                        destination: URL(string: comp.registrationUrl)!
                    )
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .navigationTitle("Detail")
    }
}
