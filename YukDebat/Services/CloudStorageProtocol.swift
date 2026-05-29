//
//  CloudStorageProtocol.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

protocol CloudStorageProtocol {
    func uploadPosterFile(fileData: Data) async throws -> String
    func deletePosterFile(fileUrl: String) async throws
}
