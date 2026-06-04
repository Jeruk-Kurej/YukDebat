//
//  GeminiService.swift
//  YukDebat
//
//  Created by Hanzelius on 04/06/26.
//

// MARK: - AI - Protocols

import Foundation

/// Contract for AI-driven text generation services.
protocol GeminiServiceProtocol {
    
    /// Generates content based on systemic prompts.
    func generateMotion() async throws -> String
}
