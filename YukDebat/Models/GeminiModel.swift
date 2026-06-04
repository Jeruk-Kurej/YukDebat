//
//  GeminiModel.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 04/06/26.
//

import Foundation

struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Decodable {
    let content: GeminiContent
}

struct GeminiContent: Decodable {
    let parts: [GeminiPart]
}

struct GeminiPart: Decodable {
    let text: String
}

