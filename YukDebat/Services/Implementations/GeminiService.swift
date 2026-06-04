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

    private var apiKey: String {
        return APIKey.gemini
    }
    private let endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    private let systemPrompt = """
        Bertindaklah sebagai kritikus budaya dan juri debat milenial yang progresif.
        Hasilkan 1 mosi debat yang segar, provokatif, dan tidak menggunakan pola kalimat "Dewan ini...".

        TEMA: Isu sosial modern, etika teknologi, gaya hidup, atau kebijakan masa depan.

        SYARAT MUTLAK:
        1. Hindari kata-kata "Dewan ini" atau "Pemerintah harus".
        2. Gunakan gaya bahasa yang to-the-point, berani, dan memancing perdebatan.
        3. Hasilkan 1 kalimat yang memicu dilema etis (misalnya: memilih antara kebebasan individu vs kepentingan kolektif).
        4. TANPA penjelasan, TANPA tanda kutip, TANPA format markdown, TANPA nomor.
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

        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard
            let motionText = result.candidates.first?.content.parts.first?.text
        else {
            throw URLError(.cannotParseResponse)
        }

        return motionText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

