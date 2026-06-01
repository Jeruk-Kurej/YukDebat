//
//  SparringRoomModel.swift
//  YukDebat
//
//  Created by Keane Juan Suryanto on 01/06/26.
//

import Foundation

/// Represents the data structure for a Sparring Room (open spar) session.
struct SparringRoomModel: Codable, Identifiable {
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
    
    func isRoomFull() -> Bool {
        return participants.count >= 8
    }
    
    func hasIdealTeams() -> Bool {
        return !participants.isEmpty && participants.count % 2 == 0
    }
}
