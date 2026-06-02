//
//  AppButton.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import SwiftUI

struct AppButton: View {
    let title: String
    let color: Color
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.headline).foregroundStyle(.white).frame(maxWidth: .infinity)
        .padding().background(color).clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
    }
}

#Preview {
    AppButton(
        title: "Join Sparring",
        color: Color.btnPositive,
        icon: "person.2.fill"
    )
    .padding()
}
