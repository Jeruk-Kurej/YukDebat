//
//  UserModel.swift
//  YukDebatCuyy
//
//  Created by Bryan Carlie Lukito Setiawan on 26/05/26.
//

// MARK: - UserModel - Model

import Foundation

/// Represents the user's identity and system access rights.
struct UserModel: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var role: UserRole
    var isActive: Bool
    let createdAt: Date
}
