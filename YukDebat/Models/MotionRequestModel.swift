//
//  MotionRequestModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import Foundation

/// Defines the structure for a custom motion submitted by a Debater.
struct MotionRequestModel: Codable, Identifiable {
    let id: String
    let title: String
    let submitterId: String
    var status: ReviewStatus
    let submittedAt: Date
}
