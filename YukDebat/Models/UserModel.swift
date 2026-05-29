//
//  UserModel.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import Foundation

struct UserModel: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var role: UserRole
    var isActive: Bool
    let createdAt: Date
}
