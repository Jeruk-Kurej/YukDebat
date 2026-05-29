//
//  ParticipantModel.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import Foundation

struct ParticipantModel: Codable, Identifiable {
    var id: String { userId }
    let userId: String
    let roleSlot: RoleSlotType
    let regMode: RegMode
}
