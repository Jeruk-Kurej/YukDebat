//
//  ReviewStatus.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 29/05/26.
//

// MARK: - ReviewStatus - Enum

import Foundation

/// Represents the moderation state of user-generated content or role upgrade requests.
enum ReviewStatus: String, Codable {
    case pending = "PENDING"
    case active = "ACTIVE"
    case rejected = "REJECTED"
}
