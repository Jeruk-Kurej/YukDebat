//
//  MockCloudFunctions.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

// MARK: - CloudFunctions - Mocks

import Foundation

/// Mock implementation for proxying Cloud Function calls.
class CloudFunctionsMock: CloudFunctionsProtocol {
    
    func callExternalAPI(endpoint: String, parameters: [String: Any]) async throws -> [String: Any] {
        // Simulasi latensi jaringan
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return [
            "id": "motion_mock_001",
            "title": "Dewan ini akan mewajibkan kebijakan lingkungan di institusi pendidikan",
            "category": "Lingkungan"
        ]
    }
    
    func triggerCronScheduler() async throws {
        print("Mock: Background cron job triggered.")
    }
}
