//
//  GeminiService.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan
//

// MARK: - AI - Implementation

import Foundation

/// Concrete service for interacting with the Google Gemini API.
/// This service implements `GeminiServiceProtocol`.
class GeminiService: GeminiServiceProtocol {

    // MARK: - Properties
    
    private let apiKey = "AQ.Ab8RN6KAHeLUsgNkH8Lh_Fm6ax1Rte4hx9e8C9feL4lCsjffSw"
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    private let systemPrompt = """
        Bertindaklah sebagai A-Core (Ketua Juri) debat tingkat nasional.
        Hasilkan tepat 1 mosi debat yang unik, berbobot, provokatif, dan seimbang.
        Topik harus relevan dengan isu masa kini (Hukum, Ekonomi, HI, Teknologi, atau Sosio-Kultural).
        
        SYARAT:
        1. HANYA keluarkan 1 kalimat mosi.
        2. TANPA penjelasan, TANPA tanda kutip, TANPA format markdown, TANPA nomor.
        3. Bahasa Indonesia baku dan akademis.
        """

    // MARK: - Methods

    /// Generates a debate motion from the Gemini API.
    /// - Returns: A `String` containing the generated motion.
    /// - Throws: `URLError` if the request fails or parsing is unsuccessful.
    func generateMotion() async throws -> String {
        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }

        let body: [String: Any] = [
            "contents": [["parts": [["text": systemPrompt]]]]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let motionText = result.candidates.first?.content.parts.first?.text else {
            throw URLError(.cannotParseResponse)
        }

        return motionText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Private DTOs (Data Transfer Objects)
// Struct ini hanya digunakan di dalam file ini, sehingga bisa diberi akses private jika perlu.

private struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]
}

private struct GeminiCandidate: Decodable {
    let content: GeminiContent
}

private struct GeminiContent: Decodable {
    let parts: [GeminiPart]
}

private struct GeminiPart: Decodable {
    let text: String
}
