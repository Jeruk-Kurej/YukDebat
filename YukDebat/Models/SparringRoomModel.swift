//
//  SparringRoomModel.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 29/05/26.
//

import Foundation

struct SparringRoomModel: Codable, Identifiable {
    let id: String
    let hostId: String
    let scheduledTime: Date
    let motionCategory: String
    let specialNotes: String
    let needAdjudicator: Bool
    let meetingLink: String
    let accessType: VisibilityType
    var state: RoomState
    var participants: [ParticipantModel]
    
    func isRoomFull() -> Bool {
        return participants.count >= 8
    }
    
    func hasIdealTeams() -> Bool {
        return participants.count > 0 && participants.count % 2 == 0
    }
}
