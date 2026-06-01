//
//  CloudFunctionsProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

/// Handles secure serverless execution blocks for proxying external APIs.
protocol CloudFunctionsProtocol {
    // MARK: - Methods
    func callExternalAPI(endpoint: String, parameters: [String: Any])
        async throws -> [String: Any]
    func triggerCronScheduler() async throws
}
