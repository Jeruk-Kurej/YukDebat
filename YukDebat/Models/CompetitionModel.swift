//
//  CompetitionModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 29/05/26.
//

// MARK: - CompetitionModel - Model

import Foundation

/// Encapsulates all details regarding a debate competition uploaded by a Promoter.
struct CompetitionModel: Codable, Identifiable {
    let id: String
    let promoterId: String
    let promoterEmail: String
    let name: String
    let description: String
    let eventDate: Date
    let registrationUrl: String
    let posterStorageUrl: String
    let status: ReviewStatus
}
