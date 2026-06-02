//
//  SparringRoomModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

// MARK: - SparringRoomModel - Model

import Foundation

/// Represents the data structure for a Sparring Room session.
struct SparringRoomModel: Codable, Identifiable {
    
    // MARK: - Properties
    
    let id: String
    let hostId: String
    let scheduledTime: Date
    let motionTitle: String
    let specialNotes: String
    let meetingLink: String
    let accessType: VisibilityType
    var state: RoomState
    var participants: [ParticipantModel]
    let isAdjudicatorNeeded: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, hostId, scheduledTime, motionTitle, specialNotes
        case meetingLink, accessType, state, participants
        case isAdjudicatorNeeded = "needAdjudicator"
    }
    
    // MARK: - Methods
    
    func isRoomFull() -> Bool {
        return participants.count >= 8
    }
    
    func hasIdealTeams() -> Bool {
        return !participants.isEmpty && participants.count % 2 == 0
    }
}
