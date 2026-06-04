//
//  CaseBuildingNoteModel.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 29/05/26.
//

// MARK: - CaseBuildingNoteModel - Model

import Foundation

/// Defines the structure for debater strategy notes, including visibility and feedback states.
struct CaseBuildingNoteModel: Codable, Identifiable {
    
    // MARK: - Properties
    
    let id: String
    var ownerId: String
    var motionTitle: String
    var argumentsRichText: String
    var visibility: VisibilityType
    var isFeedbackRequested: Bool
    var updatedAt: Date
    var feedbackText: String?
    var feedbackProviderName: String?
    
    // MARK: - Methods
    
    /// Validates if the note has sufficient content before allowing cloud synchronization.
    func validateContent() -> Bool {
        return !motionTitle.isEmpty && argumentsRichText.count >= 50
    }
}
