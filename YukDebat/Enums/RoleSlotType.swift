//
//  RoleSlotType.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import Foundation

/// Represents the specific debate position or role assigned to a participant in a British Parliamentary (BP) format.
enum RoleSlotType: String, Codable {
    case openingGovt = "OG"
    case openingOpp = "OO"
    case closingGovt = "CG"
    case closingOpp = "CO"
}
