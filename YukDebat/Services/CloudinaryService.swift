//
//  CloudinaryServiceProtocol.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 01/06/26.
//

import Foundation
import CryptoKit

/// Concrete implementation of CloudStorageProtocol using Cloudinary's REST API.
class CloudinaryService: CloudStorageProtocol {
    
    // MARK: - Properties
    
    private let cloudName = "dahvinw2b"
    private let apiKey = "755343447871684"
    private let apiSecret = "-3aaoHbU4ACu2L9Ba703dfWpkHM"
    
    // MARK: - Methods
    
    func uploadImage(imageData: Data) async throws -> String {
        let urlString = "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let timestamp = String(Int(Date().timeIntervalSince1970))
        
        // 1. Generate SHA-1 Signature for secure signed upload
        let stringToSign = "timestamp=\(timestamp)\(apiSecret)"
        let signatureData = Insecure.SHA1.hash(data: Data(stringToSign.utf8))
        let signature = signatureData.compactMap { String(format: "%02x", $0) }.joined()
        
        // 2. Prepare JSON Body with Base64 URI string format
        let base64Image = "data:image/jpeg;base64," + imageData.base64EncodedString()
        let body: [String: Any] = [
            "file": base64Image,
            "api_key": apiKey,
            "timestamp": timestamp,
            "signature": signature
        ]
        
        // 3. Configure POST Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // 4. Execute Network Call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // 5. Parse JSON to extract the secure_url
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let secureUrl = json?["secure_url"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        return secureUrl
    }
}
