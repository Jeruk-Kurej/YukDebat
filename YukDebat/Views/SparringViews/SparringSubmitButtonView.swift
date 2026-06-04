//
//  SparringSubmitButtonView.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import SwiftUI

struct SparringSubmitButtonView: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Create Sparring Room")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
        .disabled(!isEnabled)
        .background(isEnabled ? Color.btnPositive : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
