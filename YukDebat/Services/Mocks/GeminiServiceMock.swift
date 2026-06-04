//
//  GeminiServicemock.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan on 02/06/26.
//

// MARK: - AI - Mocks

import Foundation

/// Mock implementation for AI text generation to allow predictable UI previews.
class GeminiServiceMock: GeminiServiceProtocol {
    
    func generateMotion() async throws -> String {
        // Simulasi respon AI
        try await Task.sleep(nanoseconds: 300_000_000)
        return "Dewan ini akan melarang penggunaan bahan bakar fosil sepenuhnya di kota besar."
    }
}
