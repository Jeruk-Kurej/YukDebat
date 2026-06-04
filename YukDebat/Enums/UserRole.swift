//
//  UserRole.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 29/05/26.
//

// MARK: - UserRole - Enum

import Foundation

/// Defines the access level and capabilities of a user within the application ecosystem.
enum UserRole: String, Codable {
    case debater = "DEBATER"
    case adjudicator = "ADJUDICATOR"
    case admin = "ADMIN"
}
