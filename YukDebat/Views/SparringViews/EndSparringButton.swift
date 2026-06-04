//
//  EndSparringButtonView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct EndSparringButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                Text("End Sparring Session")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.btnNegative)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
}
