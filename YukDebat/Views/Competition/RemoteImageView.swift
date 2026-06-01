//
//  RemoteImageView.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 01/06/26.
//

import SwiftUI

/// A reusable smart component to display images from remote URLs (Cloudinary)
/// or fallback to legacy Base64 strings to preserve old database records.
struct RemoteImageView: View {
    
    // MARK: - Properties
    
    let source: String
    
    // MARK: - Body
    
    var body: some View {
        if source.hasPrefix("http"), let url = URL(string: source) {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                        .overlay(Image(systemName: "photo.badge.exclamationmark").foregroundStyle(.gray))
                } else {
                    Color.gray.opacity(0.2)
                        .overlay(ProgressView())
                }
            }
        } else if let data = Data(base64Encoded: source), let uiImage = UIImage(data: data) {
            // Backward compatibility for legacy Base64 data
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            Color.gray.opacity(0.2)
                .overlay(Image(systemName: "photo").foregroundStyle(.gray))
        }
    }
}
