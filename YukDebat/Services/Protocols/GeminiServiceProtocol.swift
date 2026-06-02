//
//  GeminiServiceProtocol.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 02/06/26.
//

// MARK: - AI - Protocols

import Foundation

/// Contract for AI-driven text generation services.
protocol GeminiServiceProtocol {
    
    /// Generates content based on systemic prompts.
    func generateMotion() async throws -> String
}
