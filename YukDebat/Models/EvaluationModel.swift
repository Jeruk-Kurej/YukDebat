//
//  EvaluationModel.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

/// Stores adjudicator feedback and numerical scores for a sparring session or case-building note.
/// Provides built-in logic to determine team rankings to keep business rules in the Model layer.
struct EvaluationModel: Codable, Identifiable {
    // MARK: - Mario - Properties
    let id: String
    let targetId: String
    let adjudicatorId: String
    var speakerScores: [String: Int]
    var narrativeFeedback: String
    let createdAt: Date

    // MARK: - Mario - Methods
    /// Calculates the rank of each team based on the accumulated speaker scores.
    func calculateTeamRankings() -> [String: Int] {
        // TODO: Mario - Sum scores per team and rank them
        return [:]
    }
}
