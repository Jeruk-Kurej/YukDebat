//
//  GeminiService.swift
//  YukDebat
//
//  Created by Bryan Carlie Lukito Setiawan
//

import Foundation

class GeminiService {
    // ⚠️ PASTE API KEY DARI GOOGLE AI STUDIO DI SINI ⚠️
    private let apiKey = "AQ.Ab8RN6KAHeLUsgNkH8Lh_Fm6ax1Rte4hx9e8C9feL4lCsjffSw"

    // Endpoint standar Gemini 1.5 Flash
    private let endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    private let systemPrompt = """
        Bertindaklah sebagai A-Core (Ketua Juri) debat tingkat nasional. 
        Hasilkan tepat 1 mosi (judul topik) debat yang unik, berbobot, provokatif, dan seimbang untuk sisi Afirmatif dan Oposisi. 
        Topik harus relevan dengan isu masa kini (bisa seputar Hukum, Ekonomi, Hubungan Internasional, Teknologi, atau Sosio-Kultural).

        Buatlah mosi yang variatif, fleksibel, dan tidak monoton. Kamu TIDAK HARUS selalu menggunakan frasa "Dewan ini". Kamu sangat dianjurkan untuk menggunakan format mosi yang lebih dinamis seperti:
        - "Sebagai [Aktor/Negara/Organisasi], pemerintah akan..."
        - "Di negara dengan tingkat korupsi tinggi, hukum harus..."
        - "Dunia pasca-pandemi mengharuskan..."
        - Atau format pernyataan akademis lain yang tajam.

        SYARAT MUTLAK:
        1. HANYA keluarkan 1 kalimat mosi tersebut.
        2. TANPA penjelasan, TANPA tanda kutip, TANPA format markdown, TANPA nomor awalan.
        3. Bahasa yang digunakan harus Bahasa Indonesia baku, terstruktur, dan akademis.
        """

    func generateMotion() async throws -> String {
        // Tempelkan apiKey langsung di URL. Ini cara paling stabil.
        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }

        let body: [String: Any] = [
            "contents": [["parts": [["text": systemPrompt]]]]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // KITA HAPUS HEADER X-goog-api-key KARENA SERING BIKIN ERROR 401

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode != 200 {
            let errorMsg =
                String(data: data, encoding: .utf8) ?? "Unknown error"
            print(
                "❌ GEMINI API REJECTED (Status \(httpResponse.statusCode)): \(errorMsg)"
            )
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(GeminiResponse.self, from: data)

        if let motionText = result.candidates.first?.content.parts.first?.text {
            return motionText.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
}

// MARK: - Structs for JSON Decoding
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
