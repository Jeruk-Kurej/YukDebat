//
//  UserRole.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import Foundation

enum UserRole: String, Codable {
    case debater = "DEBATER"
    case adjudicator = "ADJUDICATOR"
    case promoter = "PROMOTER"
    case admin = "ADMIN"
}
