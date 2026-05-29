//
//  EvaluationModel.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

struct EvaluationModel: Codable, Identifiable {
    let id: String
    let targetId: String
    let adjudicatorId: String
    var speakerScores: [String: Int]
    var narrativeFeedback: String
    let createdAt: Date
    
    func calculateTeamRankings() -> [String: Int] {
        return [:]
    }
}

