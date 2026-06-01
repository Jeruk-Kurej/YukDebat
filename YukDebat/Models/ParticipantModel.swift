//
//  ParticipantModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import Foundation

/// Represents an individual participant within a Sparring Room to manage slot allocation.
/// Isolated in its own file to maintain the Single Responsibility Principle.
struct ParticipantModel: Codable, Identifiable {
    // MARK: - Properties
    var id: String { userId }
    let userId: String
    let roleSlot: RoleSlotType
    let regMode: RegMode
}
