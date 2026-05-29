//
//  MockCloudFunctions.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

class MockCloudFunctions: CloudFunctionsProtocol {
    func callExternalAPI(endpoint: String, parameters: [String: Any]) async throws -> [String: Any] {
        try await Task.sleep(nanoseconds: 800_000_000) // Simulasi loading API
        return [
            "id": "motion_001",
            "title": "Dewan ini akan mewajibkan kuota berbasis gender di parlemen",
            "category": "Politik & Sosial"
        ]
    }
    
    func triggerCronScheduler() async throws {
        print("Mock: Triggered background cron job to cancel empty rooms.")
    }
}
