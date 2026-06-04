//
//  ParticipantModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

// MARK: - ParticipantModel - Model

import Foundation

/// Represents an individual participant within a Sparring Room to manage slot allocation.
struct ParticipantModel: Codable, Identifiable {
    var id: String { userId }
    let userId: String
    let userName: String
    let roleSlot: RoleSlotType
    let regMode: RegMode
}
