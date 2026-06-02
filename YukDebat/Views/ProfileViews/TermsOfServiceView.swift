//
//  TermsOfServiceView.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 02/06/26.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Terms of Service")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.textCharcoal)
                    
                    Text("Effective Date: June 2026")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
                
                Group {
                    tosSection(
                        title: "1. Acceptance of Terms",
                        content: "By accessing and using YukDebat, you agree to be bound by these Terms of Service. If you do not agree to all the terms and conditions, you must not use the application."
                    )
                    
                    tosSection(
                        title: "2. Community & Sparring Conduct",
                        content: "YukDebat is designed for competitive debate practice. You agree to maintain a respectful, professional, and inclusive environment during all Sparring sessions. Harassment, ad hominem attacks, or hate speech will result in immediate account suspension by our Administration team."
                    )
                    
                    tosSection(
                        title: "3. Case Building Notes & Intellectual Property",
                        content: "The arguments and notes you create remain your intellectual property. However, by setting your notes to 'Public Access', you grant YukDebat Adjudicators and the community the right to read, review, and provide feedback on your content."
                    )
                    
                    tosSection(
                        title: "4. Adjudicator Responsibilities",
                        content: "Users granted the 'Adjudicator' role are expected to provide constructive, fair, and unbiased feedback. YukDebat reserves the right to revoke Adjudicator privileges if the feedback provided is deemed unhelpful or toxic."
                    )
                    
                    tosSection(
                        title: "5. Privacy & Data Handling",
                        content: "Your email, sparring history, and private notes are securely stored and will not be shared with third parties. For detailed information, please refer to our Privacy Policy."
                    )
                }
                
                Spacer(minLength: 40)
            }
            .padding(24)
        }
        .background(Color.bgCream.ignoresSafeArea())
        .navigationTitle("TOS")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // UI Komponen kecil agar rapi
    @ViewBuilder
    private func tosSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.textCharcoal)
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
}
