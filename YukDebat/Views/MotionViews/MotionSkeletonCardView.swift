//
//  MotionSkeletonCardView.swift
//  YukDebat
//
//  Created by Hanzelius on 04/06/26.
//

import SwiftUI

struct MotionSkeletonCardView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 80, height: 16)
                Spacer()
                Circle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 24, height: 24)
            }

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 22)

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 200, height: 22)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        .opacity(isAnimating ? 0.5 : 1.0)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 0.8).repeatForever(
                    autoreverses: true
                )
            ) {
                isAnimating = true
            }
        }
    }
}
