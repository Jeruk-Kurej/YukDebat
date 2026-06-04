//
//  VisibilityType.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 29/05/26.
//

// MARK: - VisibilityType - Enum

import Foundation

/// Determines the privacy level of user-generated content, such as case building notes or sparring rooms.
enum VisibilityType: String, Codable {
    case publicAccess = "PUBLIC"
    case privateAccess = "PRIVATE"
}
