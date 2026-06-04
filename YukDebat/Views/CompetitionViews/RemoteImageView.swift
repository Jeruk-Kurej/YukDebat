//
//  RemoteImageView.swift
//  YukDebat
//
//  Created by Hanzelius Kwan on 01/06/26.
//

import SwiftUI
<<<<<<< HEAD
=======
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let urlString: String
    private static let cache = NSCache<NSString, UIImage>()
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func load() {
        if let cachedImage = Self.cache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    Self.cache.setObject(uiImage, forKey: self.urlString as NSString)
                    await MainActor.run {
                        self.image = uiImage
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
>>>>>>> main

/// A reusable smart component to display images from remote URLs (Cloudinary)
/// or fallback to legacy Base64 strings to preserve old database records.
struct RemoteImageView: View {
    
    // MARK: - Properties
    
    let source: String
<<<<<<< HEAD
=======
    @StateObject private var loader: ImageLoader
    
    init(source: String) {
        self.source = source
        _loader = StateObject(wrappedValue: ImageLoader(urlString: source))
    }
>>>>>>> main
    
    // MARK: - Body
    
    var body: some View {
<<<<<<< HEAD
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
=======
        if source.hasPrefix("http") {
            if let image = loader.image {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Color.gray.opacity(0.2)
                    .overlay(ProgressView())
                    .task {
                        loader.load()
                    }
>>>>>>> main
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
