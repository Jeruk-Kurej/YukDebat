//
//  CompetitionModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 29/05/26.
//

import Foundation

/// Encapsulates all details regarding a debate competition uploaded by a Promoter.
/// Includes the ReviewStatus to support the Admin moderation workflow before going public.
struct CompetitionModel: Codable, Identifiable {
    // MARK: - Properties
    struct CompetitionModel: Codable, Identifiable {
        let id: String
        let promoterId: String
        let promoterEmail: String
        let name: String
        let description: String
        let eventDate: Date  // Tambahan
        let registrationUrl: String  // Tambahan
        let posterStorageUrl: String
        let status: ReviewStatus
    }
}
