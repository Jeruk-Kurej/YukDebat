//
//  EvaluationModel.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

// MARK: - EvaluationModel - Model

import Foundation

/// Stores adjudicator feedback and numerical scores for a sparring session or case-building note.
struct EvaluationModel: Codable, Identifiable {
    
    // MARK: - Properties
    
    let id: String
    let targetId: String
    let adjudicatorId: String
    var speakerScores: [String: Int]
    var narrativeFeedback: String
    let createdAt: Date
    
    // MARK: - Methods
    
    /// Calculates the rank of each team based on the accumulated speaker scores.
    func calculateTeamRankings() -> [String: Int] {
        // Business logic for summation and ranking will be implemented here
        return [:]
    }
}
