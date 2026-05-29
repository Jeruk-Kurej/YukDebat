//
//  CloudFunctionsProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

protocol CloudFunctionsProtocol {
    func callExternalAPI(endpoint: String, parameters: [String: Any]) async throws -> [String: Any]
    func triggerCronScheduler() async throws
}
