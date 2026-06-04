//
//  CloudFunctionsServiceProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

// MARK: - CloudFunctions - Protocols

import Foundation

/// Defines serverless execution contracts for external API interactions.
protocol CloudFunctionsServiceProtocol {

    /// Executes a server-side logic block.
    func callExternalAPI(endpoint: String, parameters: [String: Any])
        async throws -> [String: Any]

    /// Triggers background task schedulers.
    func triggerCronScheduler() async throws
}
