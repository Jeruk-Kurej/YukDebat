//
//  AdjudicatorRequestModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

// MARK: - AdjudicatorRequestModel - Model

import FirebaseFirestore
import Foundation

/// Encapsulates data for a debater's application to upgrade their role to an Adjudicator.
struct AdjudicatorRequestModel: Identifiable, Equatable {
    let id: String
    let userId: String
    let userEmail: String
    let fullName: String
    let experience: String
    let certificateUrl: String
    var status: ReviewStatus
    let submittedAt: Date
}
