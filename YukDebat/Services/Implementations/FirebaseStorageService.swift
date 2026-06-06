//
//  FirebaseStorageService.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 01-06-2026.
//

import Foundation
import FirebaseStorage

// MARK: - Typealias

typealias FirebaseUploadProgressHandler = (Double) -> Void

// MARK: - Protocol

protocol FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func deleteFile(
        path: String
    ) async throws

    func downloadURL(
        path: String
    ) async throws -> URL
}

// MARK: - Error

enum FirebaseStorageServiceError: LocalizedError {

    case invalidData
    case invalidFileName
    case invalidMimeType
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidURL
    case invalidPath
    case fileTooLarge
    case unsupportedFileType
    case metadataCreationFailed
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data"
        case .invalidFileName:
            return "Invalid file name"
        case .invalidMimeType:
            return "Invalid mime type"
        case .uploadFailed:
            return "Upload failed"
        case .downloadFailed:
            return "Download failed"
        case .deleteFailed:
            return "Delete failed"
        case .invalidURL:
            return "Invalid URL"
        case .invalidPath:
            return "Invalid path"
        case .fileTooLarge:
            return "File too large"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .metadataCreationFailed:
            return "Metadata creation failed"
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Upload Result

struct UploadResult {

    let path: String
    let fileName: String
    let downloadURL: URL
    let contentType: String
    let uploadedAt: Date
}

// MARK: - Upload Progress

struct UploadProgress {

    let totalBytes: Int64
    let transferredBytes: Int64

    var percentage: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(transferredBytes)
            / Double(totalBytes)
    }
}

// MARK: - Image Upload Request

struct ImageUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "image/jpeg",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Video Upload Request

struct VideoUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "video/mp4",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Document Upload Request

struct DocumentUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String,
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Path Builder

enum StoragePathBuilder {

    static func imagePath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/images/\(fileName)"
    }

    static func videoPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/videos/\(fileName)"
    }

    static func documentPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/documents/\(fileName)"
    }

    static func avatarPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/avatar/\(fileName)"
    }

    static func bannerPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/banner/\(fileName)"
    }

    static func debateImagePath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/images/\(fileName)"
    }

    static func debateVideoPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/videos/\(fileName)"
    }

    static func debateAttachmentPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/attachments/\(fileName)"
    }
}

// MARK: - Metadata Builder

enum StorageMetadataBuilder {

    static func make(
        contentType: String,
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = contentType
        object.customMetadata = metadata

        return object
    }

    static func imageMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "image/jpeg"
        object.customMetadata = metadata

        return object
    }

    static func videoMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "video/mp4"
        object.customMetadata = metadata

        return object
    }

    static func pdfMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "application/pdf"
        object.customMetadata = metadata

        return object
    }
}

// MARK: - Validator

enum StorageValidator {

    static let maxImageSize: Int = 10_000_000

    static let maxVideoSize: Int = 150_000_000

    static let maxDocumentSize: Int = 50_000_000

    static func validateImage(
        _ request: ImageUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxImageSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateVideo(
        _ request: VideoUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxVideoSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateDocument(
        _ request: DocumentUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxDocumentSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }
}

// MARK: - Service

final class FirebaseStorageService:
    FirebaseStorageServiceProtocol {
    
    private let storage: Storage
    
    init(
        storage: Storage = .storage()
    ) {
        self.storage = storage
    }
}

// MARK: - Upload Image

func uploadImage(
    request: ImageUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateImage(request)

    let path = StoragePathBuilder.imagePath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Video

func uploadVideo(
    request: VideoUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateVideo(request)

    let path = StoragePathBuilder.videoPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Document

func uploadDocument(
    request: DocumentUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateDocument(request)

    let path = StoragePathBuilder.documentPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Delete

func deleteFile(
    path: String
) async throws {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    try await reference.delete()
}

// MARK: - Download URL

func downloadURL(
    path: String
) async throws -> URL {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    return try await reference.downloadURL()
}

// MARK: - Private Upload

private func upload(
    data: Data,
    path: String,
    metadata: StorageMetadata,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    let reference = storage.reference(
        withPath: path
    )

    return try await withCheckedThrowingContinuation {
        continuation in

        let task = reference.putData(
            data,
            metadata: metadata
        )

        task.observe(.progress) {
            snapshot in

            guard
                let value = snapshot.progress
            else {
                return
            }

            let percent =
                Double(value.completedUnitCount)
                / Double(value.totalUnitCount)

            progress?(percent)
        }

        task.observe(.success) { _ in

            Task {

                do {

                    let url =
                        try await reference.downloadURL()

                    let result = UploadResult(
                        path: path,
                        fileName: reference.name,
                        downloadURL: url,
                        contentType:
                            metadata.contentType ?? "",
                        uploadedAt: Date()
                    )

                    continuation.resume(
                        returning: result
                    )

                } catch {

                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }

        task.observe(.failure) {
            snapshot in

            if let error = snapshot.error {

                continuation.resume(
                    throwing: error
                )

                return
            }

            continuation.resume(
                throwing:
                    FirebaseStorageServiceError
                    .uploadFailed
            )
        }
    }
}
}

// MARK: - Avatar Upload

extension FirebaseStorageService {

func uploadAvatar(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + ".jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadAvatarThumbnail(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_thumb.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)/thumbnail"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadProfileImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_profile.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "profiles/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadBannerImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_banner.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "banners/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}
}

// MARK: - Debate Upload

extension FirebaseStorageService {

func uploadDebateThumbnail(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateCover(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + "_cover.jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateAttachment(
    debateId: String,
    data: Data,
    fileName: String,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        DocumentUploadRequest(
            data: data,
            fileName: fileName,
            folder: "debates/\(debateId)",
            contentType:
                "application/octet-stream"
        )

    return try await uploadDocument(
        request: request,
        progress: progress
    )
}

func uploadDebateVideo(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        VideoUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".mp4",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadVideo(
        request: request,
        progress: progress
    )
}
}

// MARK: - Retry Configuration

struct StorageRetryConfiguration {

    let maxRetryCount: Int

    let delay: TimeInterval

    static let `default` =
        StorageRetryConfiguration(
            maxRetryCount: 3,
            delay: 1.0
        )
}

// MARK: - Retry Helper

enum StorageRetryHelper {

    static func execute<T>(
        configuration: StorageRetryConfiguration = .default,
        operation: @escaping () async throws -> T
    ) async throws -> T {

        var currentAttempt = 0

        while true {

            do {

                return try await operation()

            } catch {

                currentAttempt += 1

                if currentAttempt >
                    configuration.maxRetryCount {

                    throw error
                }

                let nanoseconds =
                    UInt64(
                        configuration.delay
                        * 1_000_000_000
                    )

                try await Task.sleep(
                    nanoseconds: nanoseconds
                )
            }
        }
    }
}

// MARK: - Upload Category

enum UploadCategory: String {

    case avatar
    case banner
    case debateImage
    case debateVideo
    case attachment
    case document
    case unknown
}

// MARK: - Analytics Event

struct StorageAnalyticsEvent {

    let category: UploadCategory

    let fileName: String

    let fileSize: Int

    let createdAt: Date
}

// MARK: - Analytics Logger

protocol StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    )
}

// MARK: - Default Analytics Logger

final class DefaultStorageAnalyticsLogger:
    StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    ) {

        print(
            """
            [Storage]
            category: \(event.category.rawValue)
            fileName: \(event.fileName)
            fileSize: \(event.fileSize)
            """
        )
    }
}

// MARK: - Upload Context

struct UploadContext {

    let userId: String?

    let debateId: String?

    let category: UploadCategory

    init(
        userId: String? = nil,
        debateId: String? = nil,
        category: UploadCategory
    ) {

        self.userId = userId
        self.debateId = debateId
        self.category = category
    }
}

// MARK: - Filename Generator

enum StorageFileNameGenerator {

    static func image() -> String {
        UUID().uuidString + ".jpg"
    }

    static func png() -> String {
        UUID().uuidString + ".png"
    }

    static func video() -> String {
        UUID().uuidString + ".mp4"
    }

    static func pdf() -> String {
        UUID().uuidString + ".pdf"
    }

    static func attachment(
        name: String
    ) -> String {

        "\(UUID().uuidString)_\(name)"
    }
}

// MARK: - Path Constants

enum StorageFolder {

    static let users =
        "users"

    static let debates =
        "debates"

    static let documents =
        "documents"

    static let attachments =
        "attachments"

    static let videos =
        "videos"

    static let images =
        "images"
}

// MARK: - Mock Service

final class MockFirebaseStorageService:
    FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-image"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-video"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-document"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func deleteFile(
        path: String
    ) async throws {

    }

    func downloadURL(
        path: String
    ) async throws -> URL {

        URL(
            string:
                "https://example.com/download"
        )!
    }
}

// MARK: - Debug Helper

extension FirebaseStorageService {

    func debugPrintPath(
        _ path: String
    ) {

        print(
            "[FirebaseStorage] \(path)"
        )
    }

    func debugPrintFileName(
        _ fileName: String
    ) {

        print(
            "[FirebaseStorage] \(fileName)"
        )
    }

    func debugPrintSize(
        _ size: Int
    ) {

        print(
            "[FirebaseStorage] size=\(size)"
        )
    }
}

// MARK: - Utility Extension

extension FirebaseStorageService {

    func createImageRequest(
        data: Data,
        folder: String
    ) -> ImageUploadRequest {

        ImageUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.image(),
            folder: folder
        )
    }

    func createVideoRequest(
        data: Data,
        folder: String
    ) -> VideoUploadRequest {

        VideoUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.video(),
            folder: folder
        )
    }

    func createPDFRequest(
        data: Data,
        folder: String
    ) -> DocumentUploadRequest {

        DocumentUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.pdf(),
            folder: folder,
            contentType:
                "application/pdf"
        )
    }
}

// MARK: - Storage Health Check

struct StorageHealthCheck {

    let isReachable: Bool

    let checkedAt: Date

    let message: String
}

extension FirebaseStorageService {

    func healthCheck()
    async -> StorageHealthCheck {

        StorageHealthCheck(
            isReachable: true,
            checkedAt: Date(),
            message: "Firebase Storage Ready"
        )
    }
}

extension FirebaseStorageService {

    func generateTemporaryPath(
        prefix: String
    ) -> String {

        "\(prefix)/\(UUID().uuidString)"
    }

    func generateTemporaryImagePath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/images"
        )
    }

    func generateTemporaryVideoPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/videos"
        )
    }

    func generateTemporaryDocumentPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/documents"
        )
    }
}

extension FirebaseStorageService {

    func storageServiceName()
    -> String {

        "FirebaseStorageService"
    }

    func storageProviderName()
    -> String {

        "Firebase"
    }

    func storageVersion()
    -> String {

        "1.0.0"
    }

    func storageDescription()
    -> String {

        "\(storageServiceName())-\(storageVersion())"
    }
}

// MARK: - Typealias

typealias FirebaseUploadProgressHandler = (Double) -> Void

// MARK: - Protocol

protocol FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func deleteFile(
        path: String
    ) async throws

    func downloadURL(
        path: String
    ) async throws -> URL
}

// MARK: - Error

enum FirebaseStorageServiceError: LocalizedError {

    case invalidData
    case invalidFileName
    case invalidMimeType
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidURL
    case invalidPath
    case fileTooLarge
    case unsupportedFileType
    case metadataCreationFailed
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data"
        case .invalidFileName:
            return "Invalid file name"
        case .invalidMimeType:
            return "Invalid mime type"
        case .uploadFailed:
            return "Upload failed"
        case .downloadFailed:
            return "Download failed"
        case .deleteFailed:
            return "Delete failed"
        case .invalidURL:
            return "Invalid URL"
        case .invalidPath:
            return "Invalid path"
        case .fileTooLarge:
            return "File too large"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .metadataCreationFailed:
            return "Metadata creation failed"
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Upload Result

struct UploadResult {

    let path: String
    let fileName: String
    let downloadURL: URL
    let contentType: String
    let uploadedAt: Date
}

// MARK: - Upload Progress

struct UploadProgress {

    let totalBytes: Int64
    let transferredBytes: Int64

    var percentage: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(transferredBytes)
            / Double(totalBytes)
    }
}

// MARK: - Image Upload Request

struct ImageUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "image/jpeg",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Video Upload Request

struct VideoUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "video/mp4",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Document Upload Request

struct DocumentUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String,
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Path Builder

enum StoragePathBuilder {

    static func imagePath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/images/\(fileName)"
    }

    static func videoPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/videos/\(fileName)"
    }

    static func documentPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/documents/\(fileName)"
    }

    static func avatarPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/avatar/\(fileName)"
    }

    static func bannerPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/banner/\(fileName)"
    }

    static func debateImagePath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/images/\(fileName)"
    }

    static func debateVideoPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/videos/\(fileName)"
    }

    static func debateAttachmentPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/attachments/\(fileName)"
    }
}

// MARK: - Metadata Builder

enum StorageMetadataBuilder {

    static func make(
        contentType: String,
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = contentType
        object.customMetadata = metadata

        return object
    }

    static func imageMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "image/jpeg"
        object.customMetadata = metadata

        return object
    }

    static func videoMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "video/mp4"
        object.customMetadata = metadata

        return object
    }

    static func pdfMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "application/pdf"
        object.customMetadata = metadata

        return object
    }
}

// MARK: - Validator

enum StorageValidator {

    static let maxImageSize: Int = 10_000_000

    static let maxVideoSize: Int = 150_000_000

    static let maxDocumentSize: Int = 50_000_000

    static func validateImage(
        _ request: ImageUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxImageSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateVideo(
        _ request: VideoUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxVideoSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateDocument(
        _ request: DocumentUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxDocumentSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }
}

// MARK: - Service

final class FirebaseStorageService:
    FirebaseStorageServiceProtocol {
    
    private let storage: Storage
    
    init(
        storage: Storage = .storage()
    ) {
        self.storage = storage
    }
}

// MARK: - Upload Image

func uploadImage(
    request: ImageUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateImage(request)

    let path = StoragePathBuilder.imagePath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Video

func uploadVideo(
    request: VideoUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateVideo(request)

    let path = StoragePathBuilder.videoPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Document

func uploadDocument(
    request: DocumentUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateDocument(request)

    let path = StoragePathBuilder.documentPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Delete

func deleteFile(
    path: String
) async throws {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    try await reference.delete()
}

// MARK: - Download URL

func downloadURL(
    path: String
) async throws -> URL {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    return try await reference.downloadURL()
}

// MARK: - Private Upload

private func upload(
    data: Data,
    path: String,
    metadata: StorageMetadata,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    let reference = storage.reference(
        withPath: path
    )

    return try await withCheckedThrowingContinuation {
        continuation in

        let task = reference.putData(
            data,
            metadata: metadata
        )

        task.observe(.progress) {
            snapshot in

            guard
                let value = snapshot.progress
            else {
                return
            }

            let percent =
                Double(value.completedUnitCount)
                / Double(value.totalUnitCount)

            progress?(percent)
        }

        task.observe(.success) { _ in

            Task {

                do {

                    let url =
                        try await reference.downloadURL()

                    let result = UploadResult(
                        path: path,
                        fileName: reference.name,
                        downloadURL: url,
                        contentType:
                            metadata.contentType ?? "",
                        uploadedAt: Date()
                    )

                    continuation.resume(
                        returning: result
                    )

                } catch {

                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }

        task.observe(.failure) {
            snapshot in

            if let error = snapshot.error {

                continuation.resume(
                    throwing: error
                )

                return
            }

            continuation.resume(
                throwing:
                    FirebaseStorageServiceError
                    .uploadFailed
            )
        }
    }
}
}

// MARK: - Avatar Upload

extension FirebaseStorageService {

func uploadAvatar(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + ".jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadAvatarThumbnail(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_thumb.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)/thumbnail"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadProfileImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_profile.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "profiles/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadBannerImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_banner.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "banners/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}
}

// MARK: - Debate Upload

extension FirebaseStorageService {

func uploadDebateThumbnail(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateCover(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + "_cover.jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateAttachment(
    debateId: String,
    data: Data,
    fileName: String,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        DocumentUploadRequest(
            data: data,
            fileName: fileName,
            folder: "debates/\(debateId)",
            contentType:
                "application/octet-stream"
        )

    return try await uploadDocument(
        request: request,
        progress: progress
    )
}

func uploadDebateVideo(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        VideoUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".mp4",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadVideo(
        request: request,
        progress: progress
    )
}
}

// MARK: - Retry Configuration

struct StorageRetryConfiguration {

    let maxRetryCount: Int

    let delay: TimeInterval

    static let `default` =
        StorageRetryConfiguration(
            maxRetryCount: 3,
            delay: 1.0
        )
}

// MARK: - Retry Helper

enum StorageRetryHelper {

    static func execute<T>(
        configuration: StorageRetryConfiguration = .default,
        operation: @escaping () async throws -> T
    ) async throws -> T {

        var currentAttempt = 0

        while true {

            do {

                return try await operation()

            } catch {

                currentAttempt += 1

                if currentAttempt >
                    configuration.maxRetryCount {

                    throw error
                }

                let nanoseconds =
                    UInt64(
                        configuration.delay
                        * 1_000_000_000
                    )

                try await Task.sleep(
                    nanoseconds: nanoseconds
                )
            }
        }
    }
}

// MARK: - Upload Category

enum UploadCategory: String {

    case avatar
    case banner
    case debateImage
    case debateVideo
    case attachment
    case document
    case unknown
}

// MARK: - Analytics Event

struct StorageAnalyticsEvent {

    let category: UploadCategory

    let fileName: String

    let fileSize: Int

    let createdAt: Date
}

// MARK: - Analytics Logger

protocol StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    )
}

// MARK: - Default Analytics Logger

final class DefaultStorageAnalyticsLogger:
    StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    ) {

        print(
            """
            [Storage]
            category: \(event.category.rawValue)
            fileName: \(event.fileName)
            fileSize: \(event.fileSize)
            """
        )
    }
}

// MARK: - Upload Context

struct UploadContext {

    let userId: String?

    let debateId: String?

    let category: UploadCategory

    init(
        userId: String? = nil,
        debateId: String? = nil,
        category: UploadCategory
    ) {

        self.userId = userId
        self.debateId = debateId
        self.category = category
    }
}

// MARK: - Filename Generator

enum StorageFileNameGenerator {

    static func image() -> String {
        UUID().uuidString + ".jpg"
    }

    static func png() -> String {
        UUID().uuidString + ".png"
    }

    static func video() -> String {
        UUID().uuidString + ".mp4"
    }

    static func pdf() -> String {
        UUID().uuidString + ".pdf"
    }

    static func attachment(
        name: String
    ) -> String {

        "\(UUID().uuidString)_\(name)"
    }
}

// MARK: - Path Constants

enum StorageFolder {

    static let users =
        "users"

    static let debates =
        "debates"

    static let documents =
        "documents"

    static let attachments =
        "attachments"

    static let videos =
        "videos"

    static let images =
        "images"
}

// MARK: - Mock Service

final class MockFirebaseStorageService:
    FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-image"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-video"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-document"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func deleteFile(
        path: String
    ) async throws {

    }

    func downloadURL(
        path: String
    ) async throws -> URL {

        URL(
            string:
                "https://example.com/download"
        )!
    }
}

// MARK: - Debug Helper

extension FirebaseStorageService {

    func debugPrintPath(
        _ path: String
    ) {

        print(
            "[FirebaseStorage] \(path)"
        )
    }

    func debugPrintFileName(
        _ fileName: String
    ) {

        print(
            "[FirebaseStorage] \(fileName)"
        )
    }

    func debugPrintSize(
        _ size: Int
    ) {

        print(
            "[FirebaseStorage] size=\(size)"
        )
    }
}

// MARK: - Utility Extension

extension FirebaseStorageService {

    func createImageRequest(
        data: Data,
        folder: String
    ) -> ImageUploadRequest {

        ImageUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.image(),
            folder: folder
        )
    }

    func createVideoRequest(
        data: Data,
        folder: String
    ) -> VideoUploadRequest {

        VideoUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.video(),
            folder: folder
        )
    }

    func createPDFRequest(
        data: Data,
        folder: String
    ) -> DocumentUploadRequest {

        DocumentUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.pdf(),
            folder: folder,
            contentType:
                "application/pdf"
        )
    }
}

// MARK: - Storage Health Check

struct StorageHealthCheck {

    let isReachable: Bool

    let checkedAt: Date

    let message: String
}

extension FirebaseStorageService {

    func healthCheck()
    async -> StorageHealthCheck {

        StorageHealthCheck(
            isReachable: true,
            checkedAt: Date(),
            message: "Firebase Storage Ready"
        )
    }
}

extension FirebaseStorageService {

    func generateTemporaryPath(
        prefix: String
    ) -> String {

        "\(prefix)/\(UUID().uuidString)"
    }

    func generateTemporaryImagePath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/images"
        )
    }

    func generateTemporaryVideoPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/videos"
        )
    }

    func generateTemporaryDocumentPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/documents"
        )
    }
}

extension FirebaseStorageService {

    func storageServiceName()
    -> String {

        "FirebaseStorageService"
    }

    func storageProviderName()
    -> String {

        "Firebase"
    }

    func storageVersion()
    -> String {

        "1.0.0"
    }

    func storageDescription()
    -> String {

        "\(storageServiceName())-\(storageVersion())"
    }
}

// MARK: - Typealias

typealias FirebaseUploadProgressHandler = (Double) -> Void

// MARK: - Protocol

protocol FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func deleteFile(
        path: String
    ) async throws

    func downloadURL(
        path: String
    ) async throws -> URL
}

// MARK: - Error

enum FirebaseStorageServiceError: LocalizedError {

    case invalidData
    case invalidFileName
    case invalidMimeType
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidURL
    case invalidPath
    case fileTooLarge
    case unsupportedFileType
    case metadataCreationFailed
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data"
        case .invalidFileName:
            return "Invalid file name"
        case .invalidMimeType:
            return "Invalid mime type"
        case .uploadFailed:
            return "Upload failed"
        case .downloadFailed:
            return "Download failed"
        case .deleteFailed:
            return "Delete failed"
        case .invalidURL:
            return "Invalid URL"
        case .invalidPath:
            return "Invalid path"
        case .fileTooLarge:
            return "File too large"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .metadataCreationFailed:
            return "Metadata creation failed"
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Upload Result

struct UploadResult {

    let path: String
    let fileName: String
    let downloadURL: URL
    let contentType: String
    let uploadedAt: Date
}

// MARK: - Upload Progress

struct UploadProgress {

    let totalBytes: Int64
    let transferredBytes: Int64

    var percentage: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(transferredBytes)
            / Double(totalBytes)
    }
}

// MARK: - Image Upload Request

struct ImageUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "image/jpeg",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Video Upload Request

struct VideoUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "video/mp4",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Document Upload Request

struct DocumentUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String,
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Path Builder

enum StoragePathBuilder {

    static func imagePath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/images/\(fileName)"
    }

    static func videoPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/videos/\(fileName)"
    }

    static func documentPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/documents/\(fileName)"
    }

    static func avatarPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/avatar/\(fileName)"
    }

    static func bannerPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/banner/\(fileName)"
    }

    static func debateImagePath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/images/\(fileName)"
    }

    static func debateVideoPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/videos/\(fileName)"
    }

    static func debateAttachmentPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/attachments/\(fileName)"
    }
}

// MARK: - Metadata Builder

enum StorageMetadataBuilder {

    static func make(
        contentType: String,
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = contentType
        object.customMetadata = metadata

        return object
    }

    static func imageMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "image/jpeg"
        object.customMetadata = metadata

        return object
    }

    static func videoMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "video/mp4"
        object.customMetadata = metadata

        return object
    }

    static func pdfMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "application/pdf"
        object.customMetadata = metadata

        return object
    }
}

// MARK: - Validator

enum StorageValidator {

    static let maxImageSize: Int = 10_000_000

    static let maxVideoSize: Int = 150_000_000

    static let maxDocumentSize: Int = 50_000_000

    static func validateImage(
        _ request: ImageUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxImageSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateVideo(
        _ request: VideoUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxVideoSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateDocument(
        _ request: DocumentUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxDocumentSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }
}

// MARK: - Service

final class FirebaseStorageService:
    FirebaseStorageServiceProtocol {
    
    private let storage: Storage
    
    init(
        storage: Storage = .storage()
    ) {
        self.storage = storage
    }
}

// MARK: - Upload Image

func uploadImage(
    request: ImageUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateImage(request)

    let path = StoragePathBuilder.imagePath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Video

func uploadVideo(
    request: VideoUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateVideo(request)

    let path = StoragePathBuilder.videoPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Document

func uploadDocument(
    request: DocumentUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateDocument(request)

    let path = StoragePathBuilder.documentPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Delete

func deleteFile(
    path: String
) async throws {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    try await reference.delete()
}

// MARK: - Download URL

func downloadURL(
    path: String
) async throws -> URL {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    return try await reference.downloadURL()
}

// MARK: - Private Upload

private func upload(
    data: Data,
    path: String,
    metadata: StorageMetadata,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    let reference = storage.reference(
        withPath: path
    )

    return try await withCheckedThrowingContinuation {
        continuation in

        let task = reference.putData(
            data,
            metadata: metadata
        )

        task.observe(.progress) {
            snapshot in

            guard
                let value = snapshot.progress
            else {
                return
            }

            let percent =
                Double(value.completedUnitCount)
                / Double(value.totalUnitCount)

            progress?(percent)
        }

        task.observe(.success) { _ in

            Task {

                do {

                    let url =
                        try await reference.downloadURL()

                    let result = UploadResult(
                        path: path,
                        fileName: reference.name,
                        downloadURL: url,
                        contentType:
                            metadata.contentType ?? "",
                        uploadedAt: Date()
                    )

                    continuation.resume(
                        returning: result
                    )

                } catch {

                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }

        task.observe(.failure) {
            snapshot in

            if let error = snapshot.error {

                continuation.resume(
                    throwing: error
                )

                return
            }

            continuation.resume(
                throwing:
                    FirebaseStorageServiceError
                    .uploadFailed
            )
        }
    }
}
}

// MARK: - Avatar Upload

extension FirebaseStorageService {

func uploadAvatar(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + ".jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadAvatarThumbnail(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_thumb.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)/thumbnail"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadProfileImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_profile.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "profiles/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadBannerImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_banner.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "banners/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}
}

// MARK: - Debate Upload

extension FirebaseStorageService {

func uploadDebateThumbnail(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateCover(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + "_cover.jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateAttachment(
    debateId: String,
    data: Data,
    fileName: String,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        DocumentUploadRequest(
            data: data,
            fileName: fileName,
            folder: "debates/\(debateId)",
            contentType:
                "application/octet-stream"
        )

    return try await uploadDocument(
        request: request,
        progress: progress
    )
}

func uploadDebateVideo(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        VideoUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".mp4",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadVideo(
        request: request,
        progress: progress
    )
}
}

// MARK: - Retry Configuration

struct StorageRetryConfiguration {

    let maxRetryCount: Int

    let delay: TimeInterval

    static let `default` =
        StorageRetryConfiguration(
            maxRetryCount: 3,
            delay: 1.0
        )
}

// MARK: - Retry Helper

enum StorageRetryHelper {

    static func execute<T>(
        configuration: StorageRetryConfiguration = .default,
        operation: @escaping () async throws -> T
    ) async throws -> T {

        var currentAttempt = 0

        while true {

            do {

                return try await operation()

            } catch {

                currentAttempt += 1

                if currentAttempt >
                    configuration.maxRetryCount {

                    throw error
                }

                let nanoseconds =
                    UInt64(
                        configuration.delay
                        * 1_000_000_000
                    )

                try await Task.sleep(
                    nanoseconds: nanoseconds
                )
            }
        }
    }
}

// MARK: - Upload Category

enum UploadCategory: String {

    case avatar
    case banner
    case debateImage
    case debateVideo
    case attachment
    case document
    case unknown
}

// MARK: - Analytics Event

struct StorageAnalyticsEvent {

    let category: UploadCategory

    let fileName: String

    let fileSize: Int

    let createdAt: Date
}

// MARK: - Analytics Logger

protocol StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    )
}

// MARK: - Default Analytics Logger

final class DefaultStorageAnalyticsLogger:
    StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    ) {

        print(
            """
            [Storage]
            category: \(event.category.rawValue)
            fileName: \(event.fileName)
            fileSize: \(event.fileSize)
            """
        )
    }
}

// MARK: - Upload Context

struct UploadContext {

    let userId: String?

    let debateId: String?

    let category: UploadCategory

    init(
        userId: String? = nil,
        debateId: String? = nil,
        category: UploadCategory
    ) {

        self.userId = userId
        self.debateId = debateId
        self.category = category
    }
}

// MARK: - Filename Generator

enum StorageFileNameGenerator {

    static func image() -> String {
        UUID().uuidString + ".jpg"
    }

    static func png() -> String {
        UUID().uuidString + ".png"
    }

    static func video() -> String {
        UUID().uuidString + ".mp4"
    }

    static func pdf() -> String {
        UUID().uuidString + ".pdf"
    }

    static func attachment(
        name: String
    ) -> String {

        "\(UUID().uuidString)_\(name)"
    }
}

// MARK: - Path Constants

enum StorageFolder {

    static let users =
        "users"

    static let debates =
        "debates"

    static let documents =
        "documents"

    static let attachments =
        "attachments"

    static let videos =
        "videos"

    static let images =
        "images"
}

// MARK: - Mock Service

final class MockFirebaseStorageService:
    FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-image"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-video"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-document"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func deleteFile(
        path: String
    ) async throws {

    }

    func downloadURL(
        path: String
    ) async throws -> URL {

        URL(
            string:
                "https://example.com/download"
        )!
    }
}

// MARK: - Debug Helper

extension FirebaseStorageService {

    func debugPrintPath(
        _ path: String
    ) {

        print(
            "[FirebaseStorage] \(path)"
        )
    }

    func debugPrintFileName(
        _ fileName: String
    ) {

        print(
            "[FirebaseStorage] \(fileName)"
        )
    }

    func debugPrintSize(
        _ size: Int
    ) {

        print(
            "[FirebaseStorage] size=\(size)"
        )
    }
}

// MARK: - Utility Extension

extension FirebaseStorageService {

    func createImageRequest(
        data: Data,
        folder: String
    ) -> ImageUploadRequest {

        ImageUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.image(),
            folder: folder
        )
    }

    func createVideoRequest(
        data: Data,
        folder: String
    ) -> VideoUploadRequest {

        VideoUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.video(),
            folder: folder
        )
    }

    func createPDFRequest(
        data: Data,
        folder: String
    ) -> DocumentUploadRequest {

        DocumentUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.pdf(),
            folder: folder,
            contentType:
                "application/pdf"
        )
    }
}

// MARK: - Storage Health Check

struct StorageHealthCheck {

    let isReachable: Bool

    let checkedAt: Date

    let message: String
}

extension FirebaseStorageService {

    func healthCheck()
    async -> StorageHealthCheck {

        StorageHealthCheck(
            isReachable: true,
            checkedAt: Date(),
            message: "Firebase Storage Ready"
        )
    }
}

extension FirebaseStorageService {

    func generateTemporaryPath(
        prefix: String
    ) -> String {

        "\(prefix)/\(UUID().uuidString)"
    }

    func generateTemporaryImagePath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/images"
        )
    }

    func generateTemporaryVideoPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/videos"
        )
    }

    func generateTemporaryDocumentPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/documents"
        )
    }
}

extension FirebaseStorageService {

    func storageServiceName()
    -> String {

        "FirebaseStorageService"
    }

    func storageProviderName()
    -> String {

        "Firebase"
    }

    func storageVersion()
    -> String {

        "1.0.0"
    }

    func storageDescription()
    -> String {

        "\(storageServiceName())-\(storageVersion())"
    }
}

// MARK: - Typealias

typealias FirebaseUploadProgressHandler = (Double) -> Void

// MARK: - Protocol

protocol FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func deleteFile(
        path: String
    ) async throws

    func downloadURL(
        path: String
    ) async throws -> URL
}

// MARK: - Error

enum FirebaseStorageServiceError: LocalizedError {

    case invalidData
    case invalidFileName
    case invalidMimeType
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidURL
    case invalidPath
    case fileTooLarge
    case unsupportedFileType
    case metadataCreationFailed
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data"
        case .invalidFileName:
            return "Invalid file name"
        case .invalidMimeType:
            return "Invalid mime type"
        case .uploadFailed:
            return "Upload failed"
        case .downloadFailed:
            return "Download failed"
        case .deleteFailed:
            return "Delete failed"
        case .invalidURL:
            return "Invalid URL"
        case .invalidPath:
            return "Invalid path"
        case .fileTooLarge:
            return "File too large"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .metadataCreationFailed:
            return "Metadata creation failed"
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Upload Result

struct UploadResult {

    let path: String
    let fileName: String
    let downloadURL: URL
    let contentType: String
    let uploadedAt: Date
}

// MARK: - Upload Progress

struct UploadProgress {

    let totalBytes: Int64
    let transferredBytes: Int64

    var percentage: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(transferredBytes)
            / Double(totalBytes)
    }
}

// MARK: - Image Upload Request

struct ImageUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "image/jpeg",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Video Upload Request

struct VideoUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "video/mp4",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Document Upload Request

struct DocumentUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String,
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Path Builder

enum StoragePathBuilder {

    static func imagePath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/images/\(fileName)"
    }

    static func videoPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/videos/\(fileName)"
    }

    static func documentPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/documents/\(fileName)"
    }

    static func avatarPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/avatar/\(fileName)"
    }

    static func bannerPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/banner/\(fileName)"
    }

    static func debateImagePath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/images/\(fileName)"
    }

    static func debateVideoPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/videos/\(fileName)"
    }

    static func debateAttachmentPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/attachments/\(fileName)"
    }
}

// MARK: - Metadata Builder

enum StorageMetadataBuilder {

    static func make(
        contentType: String,
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = contentType
        object.customMetadata = metadata

        return object
    }

    static func imageMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "image/jpeg"
        object.customMetadata = metadata

        return object
    }

    static func videoMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "video/mp4"
        object.customMetadata = metadata

        return object
    }

    static func pdfMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "application/pdf"
        object.customMetadata = metadata

        return object
    }
}

// MARK: - Validator

enum StorageValidator {

    static let maxImageSize: Int = 10_000_000

    static let maxVideoSize: Int = 150_000_000

    static let maxDocumentSize: Int = 50_000_000

    static func validateImage(
        _ request: ImageUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxImageSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateVideo(
        _ request: VideoUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxVideoSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateDocument(
        _ request: DocumentUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxDocumentSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }
}

// MARK: - Service

final class FirebaseStorageService:
    FirebaseStorageServiceProtocol {
    
    private let storage: Storage
    
    init(
        storage: Storage = .storage()
    ) {
        self.storage = storage
    }
}

// MARK: - Upload Image

func uploadImage(
    request: ImageUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateImage(request)

    let path = StoragePathBuilder.imagePath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Video

func uploadVideo(
    request: VideoUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateVideo(request)

    let path = StoragePathBuilder.videoPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Document

func uploadDocument(
    request: DocumentUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateDocument(request)

    let path = StoragePathBuilder.documentPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Delete

func deleteFile(
    path: String
) async throws {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    try await reference.delete()
}

// MARK: - Download URL

func downloadURL(
    path: String
) async throws -> URL {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    return try await reference.downloadURL()
}

// MARK: - Private Upload

private func upload(
    data: Data,
    path: String,
    metadata: StorageMetadata,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    let reference = storage.reference(
        withPath: path
    )

    return try await withCheckedThrowingContinuation {
        continuation in

        let task = reference.putData(
            data,
            metadata: metadata
        )

        task.observe(.progress) {
            snapshot in

            guard
                let value = snapshot.progress
            else {
                return
            }

            let percent =
                Double(value.completedUnitCount)
                / Double(value.totalUnitCount)

            progress?(percent)
        }

        task.observe(.success) { _ in

            Task {

                do {

                    let url =
                        try await reference.downloadURL()

                    let result = UploadResult(
                        path: path,
                        fileName: reference.name,
                        downloadURL: url,
                        contentType:
                            metadata.contentType ?? "",
                        uploadedAt: Date()
                    )

                    continuation.resume(
                        returning: result
                    )

                } catch {

                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }

        task.observe(.failure) {
            snapshot in

            if let error = snapshot.error {

                continuation.resume(
                    throwing: error
                )

                return
            }

            continuation.resume(
                throwing:
                    FirebaseStorageServiceError
                    .uploadFailed
            )
        }
    }
}
}

// MARK: - Avatar Upload

extension FirebaseStorageService {

func uploadAvatar(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + ".jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadAvatarThumbnail(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_thumb.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)/thumbnail"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadProfileImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_profile.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "profiles/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadBannerImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_banner.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "banners/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}
}

// MARK: - Debate Upload

extension FirebaseStorageService {

func uploadDebateThumbnail(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateCover(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + "_cover.jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateAttachment(
    debateId: String,
    data: Data,
    fileName: String,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        DocumentUploadRequest(
            data: data,
            fileName: fileName,
            folder: "debates/\(debateId)",
            contentType:
                "application/octet-stream"
        )

    return try await uploadDocument(
        request: request,
        progress: progress
    )
}

func uploadDebateVideo(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        VideoUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".mp4",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadVideo(
        request: request,
        progress: progress
    )
}
}

// MARK: - Retry Configuration

struct StorageRetryConfiguration {

    let maxRetryCount: Int

    let delay: TimeInterval

    static let `default` =
        StorageRetryConfiguration(
            maxRetryCount: 3,
            delay: 1.0
        )
}

// MARK: - Retry Helper

enum StorageRetryHelper {

    static func execute<T>(
        configuration: StorageRetryConfiguration = .default,
        operation: @escaping () async throws -> T
    ) async throws -> T {

        var currentAttempt = 0

        while true {

            do {

                return try await operation()

            } catch {

                currentAttempt += 1

                if currentAttempt >
                    configuration.maxRetryCount {

                    throw error
                }

                let nanoseconds =
                    UInt64(
                        configuration.delay
                        * 1_000_000_000
                    )

                try await Task.sleep(
                    nanoseconds: nanoseconds
                )
            }
        }
    }
}

// MARK: - Upload Category

enum UploadCategory: String {

    case avatar
    case banner
    case debateImage
    case debateVideo
    case attachment
    case document
    case unknown
}

// MARK: - Analytics Event

struct StorageAnalyticsEvent {

    let category: UploadCategory

    let fileName: String

    let fileSize: Int

    let createdAt: Date
}

// MARK: - Analytics Logger

protocol StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    )
}

// MARK: - Default Analytics Logger

final class DefaultStorageAnalyticsLogger:
    StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    ) {

        print(
            """
            [Storage]
            category: \(event.category.rawValue)
            fileName: \(event.fileName)
            fileSize: \(event.fileSize)
            """
        )
    }
}

// MARK: - Upload Context

struct UploadContext {

    let userId: String?

    let debateId: String?

    let category: UploadCategory

    init(
        userId: String? = nil,
        debateId: String? = nil,
        category: UploadCategory
    ) {

        self.userId = userId
        self.debateId = debateId
        self.category = category
    }
}

// MARK: - Filename Generator

enum StorageFileNameGenerator {

    static func image() -> String {
        UUID().uuidString + ".jpg"
    }

    static func png() -> String {
        UUID().uuidString + ".png"
    }

    static func video() -> String {
        UUID().uuidString + ".mp4"
    }

    static func pdf() -> String {
        UUID().uuidString + ".pdf"
    }

    static func attachment(
        name: String
    ) -> String {

        "\(UUID().uuidString)_\(name)"
    }
}

// MARK: - Path Constants

enum StorageFolder {

    static let users =
        "users"

    static let debates =
        "debates"

    static let documents =
        "documents"

    static let attachments =
        "attachments"

    static let videos =
        "videos"

    static let images =
        "images"
}

// MARK: - Mock Service

final class MockFirebaseStorageService:
    FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-image"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-video"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-document"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func deleteFile(
        path: String
    ) async throws {

    }

    func downloadURL(
        path: String
    ) async throws -> URL {

        URL(
            string:
                "https://example.com/download"
        )!
    }
}

// MARK: - Debug Helper

extension FirebaseStorageService {

    func debugPrintPath(
        _ path: String
    ) {

        print(
            "[FirebaseStorage] \(path)"
        )
    }

    func debugPrintFileName(
        _ fileName: String
    ) {

        print(
            "[FirebaseStorage] \(fileName)"
        )
    }

    func debugPrintSize(
        _ size: Int
    ) {

        print(
            "[FirebaseStorage] size=\(size)"
        )
    }
}

// MARK: - Utility Extension

extension FirebaseStorageService {

    func createImageRequest(
        data: Data,
        folder: String
    ) -> ImageUploadRequest {

        ImageUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.image(),
            folder: folder
        )
    }

    func createVideoRequest(
        data: Data,
        folder: String
    ) -> VideoUploadRequest {

        VideoUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.video(),
            folder: folder
        )
    }

    func createPDFRequest(
        data: Data,
        folder: String
    ) -> DocumentUploadRequest {

        DocumentUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.pdf(),
            folder: folder,
            contentType:
                "application/pdf"
        )
    }
}

// MARK: - Storage Health Check

struct StorageHealthCheck {

    let isReachable: Bool

    let checkedAt: Date

    let message: String
}

extension FirebaseStorageService {

    func healthCheck()
    async -> StorageHealthCheck {

        StorageHealthCheck(
            isReachable: true,
            checkedAt: Date(),
            message: "Firebase Storage Ready"
        )
    }
}

extension FirebaseStorageService {

    func generateTemporaryPath(
        prefix: String
    ) -> String {

        "\(prefix)/\(UUID().uuidString)"
    }

    func generateTemporaryImagePath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/images"
        )
    }

    func generateTemporaryVideoPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/videos"
        )
    }

    func generateTemporaryDocumentPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/documents"
        )
    }
}

extension FirebaseStorageService {

    func storageServiceName()
    -> String {

        "FirebaseStorageService"
    }

    func storageProviderName()
    -> String {

        "Firebase"
    }

    func storageVersion()
    -> String {

        "1.0.0"
    }

    func storageDescription()
    -> String {

        "\(storageServiceName())-\(storageVersion())"
    }
}

// MARK: - Typealias

typealias FirebaseUploadProgressHandler = (Double) -> Void

// MARK: - Protocol

protocol FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func deleteFile(
        path: String
    ) async throws

    func downloadURL(
        path: String
    ) async throws -> URL
}

// MARK: - Error

enum FirebaseStorageServiceError: LocalizedError {

    case invalidData
    case invalidFileName
    case invalidMimeType
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidURL
    case invalidPath
    case fileTooLarge
    case unsupportedFileType
    case metadataCreationFailed
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data"
        case .invalidFileName:
            return "Invalid file name"
        case .invalidMimeType:
            return "Invalid mime type"
        case .uploadFailed:
            return "Upload failed"
        case .downloadFailed:
            return "Download failed"
        case .deleteFailed:
            return "Delete failed"
        case .invalidURL:
            return "Invalid URL"
        case .invalidPath:
            return "Invalid path"
        case .fileTooLarge:
            return "File too large"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .metadataCreationFailed:
            return "Metadata creation failed"
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Upload Result

struct UploadResult {

    let path: String
    let fileName: String
    let downloadURL: URL
    let contentType: String
    let uploadedAt: Date
}

// MARK: - Upload Progress

struct UploadProgress {

    let totalBytes: Int64
    let transferredBytes: Int64

    var percentage: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(transferredBytes)
            / Double(totalBytes)
    }
}

// MARK: - Image Upload Request

struct ImageUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "image/jpeg",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Video Upload Request

struct VideoUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "video/mp4",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Document Upload Request

struct DocumentUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String,
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Path Builder

enum StoragePathBuilder {

    static func imagePath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/images/\(fileName)"
    }

    static func videoPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/videos/\(fileName)"
    }

    static func documentPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/documents/\(fileName)"
    }

    static func avatarPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/avatar/\(fileName)"
    }

    static func bannerPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/banner/\(fileName)"
    }

    static func debateImagePath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/images/\(fileName)"
    }

    static func debateVideoPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/videos/\(fileName)"
    }

    static func debateAttachmentPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/attachments/\(fileName)"
    }
}

// MARK: - Metadata Builder

enum StorageMetadataBuilder {

    static func make(
        contentType: String,
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = contentType
        object.customMetadata = metadata

        return object
    }

    static func imageMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "image/jpeg"
        object.customMetadata = metadata

        return object
    }

    static func videoMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "video/mp4"
        object.customMetadata = metadata

        return object
    }

    static func pdfMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "application/pdf"
        object.customMetadata = metadata

        return object
    }
}

// MARK: - Validator

enum StorageValidator {

    static let maxImageSize: Int = 10_000_000

    static let maxVideoSize: Int = 150_000_000

    static let maxDocumentSize: Int = 50_000_000

    static func validateImage(
        _ request: ImageUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxImageSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateVideo(
        _ request: VideoUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxVideoSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateDocument(
        _ request: DocumentUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxDocumentSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }
}

// MARK: - Service

final class FirebaseStorageService:
    FirebaseStorageServiceProtocol {
    
    private let storage: Storage
    
    init(
        storage: Storage = .storage()
    ) {
        self.storage = storage
    }
}

// MARK: - Upload Image

func uploadImage(
    request: ImageUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateImage(request)

    let path = StoragePathBuilder.imagePath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Video

func uploadVideo(
    request: VideoUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateVideo(request)

    let path = StoragePathBuilder.videoPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Document

func uploadDocument(
    request: DocumentUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateDocument(request)

    let path = StoragePathBuilder.documentPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Delete

func deleteFile(
    path: String
) async throws {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    try await reference.delete()
}

// MARK: - Download URL

func downloadURL(
    path: String
) async throws -> URL {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    return try await reference.downloadURL()
}

// MARK: - Private Upload

private func upload(
    data: Data,
    path: String,
    metadata: StorageMetadata,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    let reference = storage.reference(
        withPath: path
    )

    return try await withCheckedThrowingContinuation {
        continuation in

        let task = reference.putData(
            data,
            metadata: metadata
        )

        task.observe(.progress) {
            snapshot in

            guard
                let value = snapshot.progress
            else {
                return
            }

            let percent =
                Double(value.completedUnitCount)
                / Double(value.totalUnitCount)

            progress?(percent)
        }

        task.observe(.success) { _ in

            Task {

                do {

                    let url =
                        try await reference.downloadURL()

                    let result = UploadResult(
                        path: path,
                        fileName: reference.name,
                        downloadURL: url,
                        contentType:
                            metadata.contentType ?? "",
                        uploadedAt: Date()
                    )

                    continuation.resume(
                        returning: result
                    )

                } catch {

                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }

        task.observe(.failure) {
            snapshot in

            if let error = snapshot.error {

                continuation.resume(
                    throwing: error
                )

                return
            }

            continuation.resume(
                throwing:
                    FirebaseStorageServiceError
                    .uploadFailed
            )
        }
    }
}
}

// MARK: - Avatar Upload

extension FirebaseStorageService {

func uploadAvatar(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + ".jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadAvatarThumbnail(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_thumb.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)/thumbnail"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadProfileImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_profile.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "profiles/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadBannerImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_banner.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "banners/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}
}

// MARK: - Debate Upload

extension FirebaseStorageService {

func uploadDebateThumbnail(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateCover(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + "_cover.jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateAttachment(
    debateId: String,
    data: Data,
    fileName: String,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        DocumentUploadRequest(
            data: data,
            fileName: fileName,
            folder: "debates/\(debateId)",
            contentType:
                "application/octet-stream"
        )

    return try await uploadDocument(
        request: request,
        progress: progress
    )
}

func uploadDebateVideo(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        VideoUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".mp4",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadVideo(
        request: request,
        progress: progress
    )
}
}

// MARK: - Retry Configuration

struct StorageRetryConfiguration {

    let maxRetryCount: Int

    let delay: TimeInterval

    static let `default` =
        StorageRetryConfiguration(
            maxRetryCount: 3,
            delay: 1.0
        )
}

// MARK: - Retry Helper

enum StorageRetryHelper {

    static func execute<T>(
        configuration: StorageRetryConfiguration = .default,
        operation: @escaping () async throws -> T
    ) async throws -> T {

        var currentAttempt = 0

        while true {

            do {

                return try await operation()

            } catch {

                currentAttempt += 1

                if currentAttempt >
                    configuration.maxRetryCount {

                    throw error
                }

                let nanoseconds =
                    UInt64(
                        configuration.delay
                        * 1_000_000_000
                    )

                try await Task.sleep(
                    nanoseconds: nanoseconds
                )
            }
        }
    }
}

// MARK: - Upload Category

enum UploadCategory: String {

    case avatar
    case banner
    case debateImage
    case debateVideo
    case attachment
    case document
    case unknown
}

// MARK: - Analytics Event

struct StorageAnalyticsEvent {

    let category: UploadCategory

    let fileName: String

    let fileSize: Int

    let createdAt: Date
}

// MARK: - Analytics Logger

protocol StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    )
}

// MARK: - Default Analytics Logger

final class DefaultStorageAnalyticsLogger:
    StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    ) {

        print(
            """
            [Storage]
            category: \(event.category.rawValue)
            fileName: \(event.fileName)
            fileSize: \(event.fileSize)
            """
        )
    }
}

// MARK: - Upload Context

struct UploadContext {

    let userId: String?

    let debateId: String?

    let category: UploadCategory

    init(
        userId: String? = nil,
        debateId: String? = nil,
        category: UploadCategory
    ) {

        self.userId = userId
        self.debateId = debateId
        self.category = category
    }
}

// MARK: - Filename Generator

enum StorageFileNameGenerator {

    static func image() -> String {
        UUID().uuidString + ".jpg"
    }

    static func png() -> String {
        UUID().uuidString + ".png"
    }

    static func video() -> String {
        UUID().uuidString + ".mp4"
    }

    static func pdf() -> String {
        UUID().uuidString + ".pdf"
    }

    static func attachment(
        name: String
    ) -> String {

        "\(UUID().uuidString)_\(name)"
    }
}

// MARK: - Path Constants

enum StorageFolder {

    static let users =
        "users"

    static let debates =
        "debates"

    static let documents =
        "documents"

    static let attachments =
        "attachments"

    static let videos =
        "videos"

    static let images =
        "images"
}

// MARK: - Mock Service

final class MockFirebaseStorageService:
    FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-image"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-video"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-document"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func deleteFile(
        path: String
    ) async throws {

    }

    func downloadURL(
        path: String
    ) async throws -> URL {

        URL(
            string:
                "https://example.com/download"
        )!
    }
}

// MARK: - Debug Helper

extension FirebaseStorageService {

    func debugPrintPath(
        _ path: String
    ) {

        print(
            "[FirebaseStorage] \(path)"
        )
    }

    func debugPrintFileName(
        _ fileName: String
    ) {

        print(
            "[FirebaseStorage] \(fileName)"
        )
    }

    func debugPrintSize(
        _ size: Int
    ) {

        print(
            "[FirebaseStorage] size=\(size)"
        )
    }
}

// MARK: - Utility Extension

extension FirebaseStorageService {

    func createImageRequest(
        data: Data,
        folder: String
    ) -> ImageUploadRequest {

        ImageUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.image(),
            folder: folder
        )
    }

    func createVideoRequest(
        data: Data,
        folder: String
    ) -> VideoUploadRequest {

        VideoUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.video(),
            folder: folder
        )
    }

    func createPDFRequest(
        data: Data,
        folder: String
    ) -> DocumentUploadRequest {

        DocumentUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.pdf(),
            folder: folder,
            contentType:
                "application/pdf"
        )
    }
}

// MARK: - Storage Health Check

struct StorageHealthCheck {

    let isReachable: Bool

    let checkedAt: Date

    let message: String
}

extension FirebaseStorageService {

    func healthCheck()
    async -> StorageHealthCheck {

        StorageHealthCheck(
            isReachable: true,
            checkedAt: Date(),
            message: "Firebase Storage Ready"
        )
    }
}

extension FirebaseStorageService {

    func generateTemporaryPath(
        prefix: String
    ) -> String {

        "\(prefix)/\(UUID().uuidString)"
    }

    func generateTemporaryImagePath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/images"
        )
    }

    func generateTemporaryVideoPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/videos"
        )
    }

    func generateTemporaryDocumentPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/documents"
        )
    }
}

extension FirebaseStorageService {

    func storageServiceName()
    -> String {

        "FirebaseStorageService"
    }

    func storageProviderName()
    -> String {

        "Firebase"
    }

    func storageVersion()
    -> String {

        "1.0.0"
    }

    func storageDescription()
    -> String {

        "\(storageServiceName())-\(storageVersion())"
    }
}

// MARK: - Typealias

typealias FirebaseUploadProgressHandler = (Double) -> Void

// MARK: - Protocol

protocol FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func deleteFile(
        path: String
    ) async throws

    func downloadURL(
        path: String
    ) async throws -> URL
}

// MARK: - Error

enum FirebaseStorageServiceError: LocalizedError {

    case invalidData
    case invalidFileName
    case invalidMimeType
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidURL
    case invalidPath
    case fileTooLarge
    case unsupportedFileType
    case metadataCreationFailed
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data"
        case .invalidFileName:
            return "Invalid file name"
        case .invalidMimeType:
            return "Invalid mime type"
        case .uploadFailed:
            return "Upload failed"
        case .downloadFailed:
            return "Download failed"
        case .deleteFailed:
            return "Delete failed"
        case .invalidURL:
            return "Invalid URL"
        case .invalidPath:
            return "Invalid path"
        case .fileTooLarge:
            return "File too large"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .metadataCreationFailed:
            return "Metadata creation failed"
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Upload Result

struct UploadResult {

    let path: String
    let fileName: String
    let downloadURL: URL
    let contentType: String
    let uploadedAt: Date
}

// MARK: - Upload Progress

struct UploadProgress {

    let totalBytes: Int64
    let transferredBytes: Int64

    var percentage: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(transferredBytes)
            / Double(totalBytes)
    }
}

// MARK: - Image Upload Request

struct ImageUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "image/jpeg",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Video Upload Request

struct VideoUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "video/mp4",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Document Upload Request

struct DocumentUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String,
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Path Builder

enum StoragePathBuilder {

    static func imagePath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/images/\(fileName)"
    }

    static func videoPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/videos/\(fileName)"
    }

    static func documentPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/documents/\(fileName)"
    }

    static func avatarPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/avatar/\(fileName)"
    }

    static func bannerPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/banner/\(fileName)"
    }

    static func debateImagePath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/images/\(fileName)"
    }

    static func debateVideoPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/videos/\(fileName)"
    }

    static func debateAttachmentPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/attachments/\(fileName)"
    }
}

// MARK: - Metadata Builder

enum StorageMetadataBuilder {

    static func make(
        contentType: String,
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = contentType
        object.customMetadata = metadata

        return object
    }

    static func imageMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "image/jpeg"
        object.customMetadata = metadata

        return object
    }

    static func videoMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "video/mp4"
        object.customMetadata = metadata

        return object
    }

    static func pdfMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "application/pdf"
        object.customMetadata = metadata

        return object
    }
}

// MARK: - Validator

enum StorageValidator {

    static let maxImageSize: Int = 10_000_000

    static let maxVideoSize: Int = 150_000_000

    static let maxDocumentSize: Int = 50_000_000

    static func validateImage(
        _ request: ImageUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxImageSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateVideo(
        _ request: VideoUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxVideoSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateDocument(
        _ request: DocumentUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxDocumentSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }
}

// MARK: - Service

final class FirebaseStorageService:
    FirebaseStorageServiceProtocol {
    
    private let storage: Storage
    
    init(
        storage: Storage = .storage()
    ) {
        self.storage = storage
    }
}

// MARK: - Upload Image

func uploadImage(
    request: ImageUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateImage(request)

    let path = StoragePathBuilder.imagePath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Video

func uploadVideo(
    request: VideoUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateVideo(request)

    let path = StoragePathBuilder.videoPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Document

func uploadDocument(
    request: DocumentUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateDocument(request)

    let path = StoragePathBuilder.documentPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Delete

func deleteFile(
    path: String
) async throws {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    try await reference.delete()
}

// MARK: - Download URL

func downloadURL(
    path: String
) async throws -> URL {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    return try await reference.downloadURL()
}

// MARK: - Private Upload

private func upload(
    data: Data,
    path: String,
    metadata: StorageMetadata,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    let reference = storage.reference(
        withPath: path
    )

    return try await withCheckedThrowingContinuation {
        continuation in

        let task = reference.putData(
            data,
            metadata: metadata
        )

        task.observe(.progress) {
            snapshot in

            guard
                let value = snapshot.progress
            else {
                return
            }

            let percent =
                Double(value.completedUnitCount)
                / Double(value.totalUnitCount)

            progress?(percent)
        }

        task.observe(.success) { _ in

            Task {

                do {

                    let url =
                        try await reference.downloadURL()

                    let result = UploadResult(
                        path: path,
                        fileName: reference.name,
                        downloadURL: url,
                        contentType:
                            metadata.contentType ?? "",
                        uploadedAt: Date()
                    )

                    continuation.resume(
                        returning: result
                    )

                } catch {

                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }

        task.observe(.failure) {
            snapshot in

            if let error = snapshot.error {

                continuation.resume(
                    throwing: error
                )

                return
            }

            continuation.resume(
                throwing:
                    FirebaseStorageServiceError
                    .uploadFailed
            )
        }
    }
}
}

// MARK: - Avatar Upload

extension FirebaseStorageService {

func uploadAvatar(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + ".jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadAvatarThumbnail(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_thumb.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)/thumbnail"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadProfileImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_profile.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "profiles/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadBannerImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_banner.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "banners/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}
}

// MARK: - Debate Upload

extension FirebaseStorageService {

func uploadDebateThumbnail(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateCover(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + "_cover.jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateAttachment(
    debateId: String,
    data: Data,
    fileName: String,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        DocumentUploadRequest(
            data: data,
            fileName: fileName,
            folder: "debates/\(debateId)",
            contentType:
                "application/octet-stream"
        )

    return try await uploadDocument(
        request: request,
        progress: progress
    )
}

func uploadDebateVideo(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        VideoUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".mp4",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadVideo(
        request: request,
        progress: progress
    )
}
}

// MARK: - Retry Configuration

struct StorageRetryConfiguration {

    let maxRetryCount: Int

    let delay: TimeInterval

    static let `default` =
        StorageRetryConfiguration(
            maxRetryCount: 3,
            delay: 1.0
        )
}

// MARK: - Retry Helper

enum StorageRetryHelper {

    static func execute<T>(
        configuration: StorageRetryConfiguration = .default,
        operation: @escaping () async throws -> T
    ) async throws -> T {

        var currentAttempt = 0

        while true {

            do {

                return try await operation()

            } catch {

                currentAttempt += 1

                if currentAttempt >
                    configuration.maxRetryCount {

                    throw error
                }

                let nanoseconds =
                    UInt64(
                        configuration.delay
                        * 1_000_000_000
                    )

                try await Task.sleep(
                    nanoseconds: nanoseconds
                )
            }
        }
    }
}

// MARK: - Upload Category

enum UploadCategory: String {

    case avatar
    case banner
    case debateImage
    case debateVideo
    case attachment
    case document
    case unknown
}

// MARK: - Analytics Event

struct StorageAnalyticsEvent {

    let category: UploadCategory

    let fileName: String

    let fileSize: Int

    let createdAt: Date
}

// MARK: - Analytics Logger

protocol StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    )
}

// MARK: - Default Analytics Logger

final class DefaultStorageAnalyticsLogger:
    StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    ) {

        print(
            """
            [Storage]
            category: \(event.category.rawValue)
            fileName: \(event.fileName)
            fileSize: \(event.fileSize)
            """
        )
    }
}

// MARK: - Upload Context

struct UploadContext {

    let userId: String?

    let debateId: String?

    let category: UploadCategory

    init(
        userId: String? = nil,
        debateId: String? = nil,
        category: UploadCategory
    ) {

        self.userId = userId
        self.debateId = debateId
        self.category = category
    }
}

// MARK: - Filename Generator

enum StorageFileNameGenerator {

    static func image() -> String {
        UUID().uuidString + ".jpg"
    }

    static func png() -> String {
        UUID().uuidString + ".png"
    }

    static func video() -> String {
        UUID().uuidString + ".mp4"
    }

    static func pdf() -> String {
        UUID().uuidString + ".pdf"
    }

    static func attachment(
        name: String
    ) -> String {

        "\(UUID().uuidString)_\(name)"
    }
}

// MARK: - Path Constants

enum StorageFolder {

    static let users =
        "users"

    static let debates =
        "debates"

    static let documents =
        "documents"

    static let attachments =
        "attachments"

    static let videos =
        "videos"

    static let images =
        "images"
}

// MARK: - Mock Service

final class MockFirebaseStorageService:
    FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-image"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-video"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-document"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func deleteFile(
        path: String
    ) async throws {

    }

    func downloadURL(
        path: String
    ) async throws -> URL {

        URL(
            string:
                "https://example.com/download"
        )!
    }
}

// MARK: - Debug Helper

extension FirebaseStorageService {

    func debugPrintPath(
        _ path: String
    ) {

        print(
            "[FirebaseStorage] \(path)"
        )
    }

    func debugPrintFileName(
        _ fileName: String
    ) {

        print(
            "[FirebaseStorage] \(fileName)"
        )
    }

    func debugPrintSize(
        _ size: Int
    ) {

        print(
            "[FirebaseStorage] size=\(size)"
        )
    }
}

// MARK: - Utility Extension

extension FirebaseStorageService {

    func createImageRequest(
        data: Data,
        folder: String
    ) -> ImageUploadRequest {

        ImageUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.image(),
            folder: folder
        )
    }

    func createVideoRequest(
        data: Data,
        folder: String
    ) -> VideoUploadRequest {

        VideoUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.video(),
            folder: folder
        )
    }

    func createPDFRequest(
        data: Data,
        folder: String
    ) -> DocumentUploadRequest {

        DocumentUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.pdf(),
            folder: folder,
            contentType:
                "application/pdf"
        )
    }
}

// MARK: - Storage Health Check

struct StorageHealthCheck {

    let isReachable: Bool

    let checkedAt: Date

    let message: String
}

extension FirebaseStorageService {

    func healthCheck()
    async -> StorageHealthCheck {

        StorageHealthCheck(
            isReachable: true,
            checkedAt: Date(),
            message: "Firebase Storage Ready"
        )
    }
}

extension FirebaseStorageService {

    func generateTemporaryPath(
        prefix: String
    ) -> String {

        "\(prefix)/\(UUID().uuidString)"
    }

    func generateTemporaryImagePath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/images"
        )
    }

    func generateTemporaryVideoPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/videos"
        )
    }

    func generateTemporaryDocumentPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/documents"
        )
    }
}

extension FirebaseStorageService {

    func storageServiceName()
    -> String {

        "FirebaseStorageService"
    }

    func storageProviderName()
    -> String {

        "Firebase"
    }

    func storageVersion()
    -> String {

        "1.0.0"
    }

    func storageDescription()
    -> String {

        "\(storageServiceName())-\(storageVersion())"
    }
}

// MARK: - Typealias

typealias FirebaseUploadProgressHandler = (Double) -> Void

// MARK: - Protocol

protocol FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func deleteFile(
        path: String
    ) async throws

    func downloadURL(
        path: String
    ) async throws -> URL
}

// MARK: - Error

enum FirebaseStorageServiceError: LocalizedError {

    case invalidData
    case invalidFileName
    case invalidMimeType
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidURL
    case invalidPath
    case fileTooLarge
    case unsupportedFileType
    case metadataCreationFailed
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data"
        case .invalidFileName:
            return "Invalid file name"
        case .invalidMimeType:
            return "Invalid mime type"
        case .uploadFailed:
            return "Upload failed"
        case .downloadFailed:
            return "Download failed"
        case .deleteFailed:
            return "Delete failed"
        case .invalidURL:
            return "Invalid URL"
        case .invalidPath:
            return "Invalid path"
        case .fileTooLarge:
            return "File too large"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .metadataCreationFailed:
            return "Metadata creation failed"
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Upload Result

struct UploadResult {

    let path: String
    let fileName: String
    let downloadURL: URL
    let contentType: String
    let uploadedAt: Date
}

// MARK: - Upload Progress

struct UploadProgress {

    let totalBytes: Int64
    let transferredBytes: Int64

    var percentage: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(transferredBytes)
            / Double(totalBytes)
    }
}

// MARK: - Image Upload Request

struct ImageUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "image/jpeg",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Video Upload Request

struct VideoUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "video/mp4",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Document Upload Request

struct DocumentUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String,
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Path Builder

enum StoragePathBuilder {

    static func imagePath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/images/\(fileName)"
    }

    static func videoPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/videos/\(fileName)"
    }

    static func documentPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/documents/\(fileName)"
    }

    static func avatarPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/avatar/\(fileName)"
    }

    static func bannerPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/banner/\(fileName)"
    }

    static func debateImagePath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/images/\(fileName)"
    }

    static func debateVideoPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/videos/\(fileName)"
    }

    static func debateAttachmentPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/attachments/\(fileName)"
    }
}

// MARK: - Metadata Builder

enum StorageMetadataBuilder {

    static func make(
        contentType: String,
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = contentType
        object.customMetadata = metadata

        return object
    }

    static func imageMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "image/jpeg"
        object.customMetadata = metadata

        return object
    }

    static func videoMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "video/mp4"
        object.customMetadata = metadata

        return object
    }

    static func pdfMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "application/pdf"
        object.customMetadata = metadata

        return object
    }
}

// MARK: - Validator

enum StorageValidator {

    static let maxImageSize: Int = 10_000_000

    static let maxVideoSize: Int = 150_000_000

    static let maxDocumentSize: Int = 50_000_000

    static func validateImage(
        _ request: ImageUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxImageSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateVideo(
        _ request: VideoUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxVideoSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateDocument(
        _ request: DocumentUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxDocumentSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }
}

// MARK: - Service

final class FirebaseStorageService:
    FirebaseStorageServiceProtocol {
    
    private let storage: Storage
    
    init(
        storage: Storage = .storage()
    ) {
        self.storage = storage
    }
}

// MARK: - Upload Image

func uploadImage(
    request: ImageUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateImage(request)

    let path = StoragePathBuilder.imagePath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Video

func uploadVideo(
    request: VideoUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateVideo(request)

    let path = StoragePathBuilder.videoPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Document

func uploadDocument(
    request: DocumentUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateDocument(request)

    let path = StoragePathBuilder.documentPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Delete

func deleteFile(
    path: String
) async throws {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    try await reference.delete()
}

// MARK: - Download URL

func downloadURL(
    path: String
) async throws -> URL {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    return try await reference.downloadURL()
}

// MARK: - Private Upload

private func upload(
    data: Data,
    path: String,
    metadata: StorageMetadata,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    let reference = storage.reference(
        withPath: path
    )

    return try await withCheckedThrowingContinuation {
        continuation in

        let task = reference.putData(
            data,
            metadata: metadata
        )

        task.observe(.progress) {
            snapshot in

            guard
                let value = snapshot.progress
            else {
                return
            }

            let percent =
                Double(value.completedUnitCount)
                / Double(value.totalUnitCount)

            progress?(percent)
        }

        task.observe(.success) { _ in

            Task {

                do {

                    let url =
                        try await reference.downloadURL()

                    let result = UploadResult(
                        path: path,
                        fileName: reference.name,
                        downloadURL: url,
                        contentType:
                            metadata.contentType ?? "",
                        uploadedAt: Date()
                    )

                    continuation.resume(
                        returning: result
                    )

                } catch {

                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }

        task.observe(.failure) {
            snapshot in

            if let error = snapshot.error {

                continuation.resume(
                    throwing: error
                )

                return
            }

            continuation.resume(
                throwing:
                    FirebaseStorageServiceError
                    .uploadFailed
            )
        }
    }
}
}

// MARK: - Avatar Upload

extension FirebaseStorageService {

func uploadAvatar(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + ".jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadAvatarThumbnail(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_thumb.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)/thumbnail"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadProfileImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_profile.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "profiles/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadBannerImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_banner.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "banners/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}
}

// MARK: - Debate Upload

extension FirebaseStorageService {

func uploadDebateThumbnail(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateCover(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + "_cover.jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateAttachment(
    debateId: String,
    data: Data,
    fileName: String,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        DocumentUploadRequest(
            data: data,
            fileName: fileName,
            folder: "debates/\(debateId)",
            contentType:
                "application/octet-stream"
        )

    return try await uploadDocument(
        request: request,
        progress: progress
    )
}

func uploadDebateVideo(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        VideoUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".mp4",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadVideo(
        request: request,
        progress: progress
    )
}
}

// MARK: - Retry Configuration

struct StorageRetryConfiguration {

    let maxRetryCount: Int

    let delay: TimeInterval

    static let `default` =
        StorageRetryConfiguration(
            maxRetryCount: 3,
            delay: 1.0
        )
}

// MARK: - Retry Helper

enum StorageRetryHelper {

    static func execute<T>(
        configuration: StorageRetryConfiguration = .default,
        operation: @escaping () async throws -> T
    ) async throws -> T {

        var currentAttempt = 0

        while true {

            do {

                return try await operation()

            } catch {

                currentAttempt += 1

                if currentAttempt >
                    configuration.maxRetryCount {

                    throw error
                }

                let nanoseconds =
                    UInt64(
                        configuration.delay
                        * 1_000_000_000
                    )

                try await Task.sleep(
                    nanoseconds: nanoseconds
                )
            }
        }
    }
}

// MARK: - Upload Category

enum UploadCategory: String {

    case avatar
    case banner
    case debateImage
    case debateVideo
    case attachment
    case document
    case unknown
}

// MARK: - Analytics Event

struct StorageAnalyticsEvent {

    let category: UploadCategory

    let fileName: String

    let fileSize: Int

    let createdAt: Date
}

// MARK: - Analytics Logger

protocol StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    )
}

// MARK: - Default Analytics Logger

final class DefaultStorageAnalyticsLogger:
    StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    ) {

        print(
            """
            [Storage]
            category: \(event.category.rawValue)
            fileName: \(event.fileName)
            fileSize: \(event.fileSize)
            """
        )
    }
}

// MARK: - Upload Context

struct UploadContext {

    let userId: String?

    let debateId: String?

    let category: UploadCategory

    init(
        userId: String? = nil,
        debateId: String? = nil,
        category: UploadCategory
    ) {

        self.userId = userId
        self.debateId = debateId
        self.category = category
    }
}

// MARK: - Filename Generator

enum StorageFileNameGenerator {

    static func image() -> String {
        UUID().uuidString + ".jpg"
    }

    static func png() -> String {
        UUID().uuidString + ".png"
    }

    static func video() -> String {
        UUID().uuidString + ".mp4"
    }

    static func pdf() -> String {
        UUID().uuidString + ".pdf"
    }

    static func attachment(
        name: String
    ) -> String {

        "\(UUID().uuidString)_\(name)"
    }
}

// MARK: - Path Constants

enum StorageFolder {

    static let users =
        "users"

    static let debates =
        "debates"

    static let documents =
        "documents"

    static let attachments =
        "attachments"

    static let videos =
        "videos"

    static let images =
        "images"
}

// MARK: - Mock Service

final class MockFirebaseStorageService:
    FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-image"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-video"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-document"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func deleteFile(
        path: String
    ) async throws {

    }

    func downloadURL(
        path: String
    ) async throws -> URL {

        URL(
            string:
                "https://example.com/download"
        )!
    }
}

// MARK: - Debug Helper

extension FirebaseStorageService {

    func debugPrintPath(
        _ path: String
    ) {

        print(
            "[FirebaseStorage] \(path)"
        )
    }

    func debugPrintFileName(
        _ fileName: String
    ) {

        print(
            "[FirebaseStorage] \(fileName)"
        )
    }

    func debugPrintSize(
        _ size: Int
    ) {

        print(
            "[FirebaseStorage] size=\(size)"
        )
    }
}

// MARK: - Utility Extension

extension FirebaseStorageService {

    func createImageRequest(
        data: Data,
        folder: String
    ) -> ImageUploadRequest {

        ImageUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.image(),
            folder: folder
        )
    }

    func createVideoRequest(
        data: Data,
        folder: String
    ) -> VideoUploadRequest {

        VideoUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.video(),
            folder: folder
        )
    }

    func createPDFRequest(
        data: Data,
        folder: String
    ) -> DocumentUploadRequest {

        DocumentUploadRequest(
            data: data,
            fileName:
                StorageFileNameGenerator.pdf(),
            folder: folder,
            contentType:
                "application/pdf"
        )
    }
}

// MARK: - Storage Health Check

struct StorageHealthCheck {

    let isReachable: Bool

    let checkedAt: Date

    let message: String
}

extension FirebaseStorageService {

    func healthCheck()
    async -> StorageHealthCheck {

        StorageHealthCheck(
            isReachable: true,
            checkedAt: Date(),
            message: "Firebase Storage Ready"
        )
    }
}

extension FirebaseStorageService {

    func generateTemporaryPath(
        prefix: String
    ) -> String {

        "\(prefix)/\(UUID().uuidString)"
    }

    func generateTemporaryImagePath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/images"
        )
    }

    func generateTemporaryVideoPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/videos"
        )
    }

    func generateTemporaryDocumentPath()
    -> String {

        generateTemporaryPath(
            prefix: "temp/documents"
        )
    }
}

extension FirebaseStorageService {

    func storageServiceName()
    -> String {

        "FirebaseStorageService"
    }

    func storageProviderName()
    -> String {

        "Firebase"
    }

    func storageVersion()
    -> String {

        "1.0.0"
    }

    func storageDescription()
    -> String {

        "\(storageServiceName())-\(storageVersion())"
    }
}

// MARK: - Typealias

typealias FirebaseUploadProgressHandler = (Double) -> Void

// MARK: - Protocol

protocol FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult

    func deleteFile(
        path: String
    ) async throws

    func downloadURL(
        path: String
    ) async throws -> URL
}

// MARK: - Error

enum FirebaseStorageServiceError: LocalizedError {

    case invalidData
    case invalidFileName
    case invalidMimeType
    case uploadFailed
    case downloadFailed
    case deleteFailed
    case invalidURL
    case invalidPath
    case fileTooLarge
    case unsupportedFileType
    case metadataCreationFailed
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data"
        case .invalidFileName:
            return "Invalid file name"
        case .invalidMimeType:
            return "Invalid mime type"
        case .uploadFailed:
            return "Upload failed"
        case .downloadFailed:
            return "Download failed"
        case .deleteFailed:
            return "Delete failed"
        case .invalidURL:
            return "Invalid URL"
        case .invalidPath:
            return "Invalid path"
        case .fileTooLarge:
            return "File too large"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .metadataCreationFailed:
            return "Metadata creation failed"
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Upload Result

struct UploadResult {

    let path: String
    let fileName: String
    let downloadURL: URL
    let contentType: String
    let uploadedAt: Date
}

// MARK: - Upload Progress

struct UploadProgress {

    let totalBytes: Int64
    let transferredBytes: Int64

    var percentage: Double {
        guard totalBytes > 0 else {
            return 0
        }

        return Double(transferredBytes)
            / Double(totalBytes)
    }
}

// MARK: - Image Upload Request

struct ImageUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "image/jpeg",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Video Upload Request

struct VideoUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String = "video/mp4",
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Document Upload Request

struct DocumentUploadRequest {

    let data: Data
    let fileName: String
    let folder: String
    let contentType: String
    let metadata: [String: String]

    init(
        data: Data,
        fileName: String,
        folder: String,
        contentType: String,
        metadata: [String: String] = [:]
    ) {
        self.data = data
        self.fileName = fileName
        self.folder = folder
        self.contentType = contentType
        self.metadata = metadata
    }
}

// MARK: - Path Builder

enum StoragePathBuilder {

    static func imagePath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/images/\(fileName)"
    }

    static func videoPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/videos/\(fileName)"
    }

    static func documentPath(
        folder: String,
        fileName: String
    ) -> String {
        "\(folder)/documents/\(fileName)"
    }

    static func avatarPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/avatar/\(fileName)"
    }

    static func bannerPath(
        userId: String,
        fileName: String
    ) -> String {
        "users/\(userId)/banner/\(fileName)"
    }

    static func debateImagePath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/images/\(fileName)"
    }

    static func debateVideoPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/videos/\(fileName)"
    }

    static func debateAttachmentPath(
        debateId: String,
        fileName: String
    ) -> String {
        "debates/\(debateId)/attachments/\(fileName)"
    }
}

// MARK: - Metadata Builder

enum StorageMetadataBuilder {

    static func make(
        contentType: String,
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = contentType
        object.customMetadata = metadata

        return object
    }

    static func imageMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "image/jpeg"
        object.customMetadata = metadata

        return object
    }

    static func videoMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "video/mp4"
        object.customMetadata = metadata

        return object
    }

    static func pdfMetadata(
        metadata: [String: String]
    ) -> StorageMetadata {

        let object = StorageMetadata()

        object.contentType = "application/pdf"
        object.customMetadata = metadata

        return object
    }
}

// MARK: - Validator

enum StorageValidator {

    static let maxImageSize: Int = 10_000_000

    static let maxVideoSize: Int = 150_000_000

    static let maxDocumentSize: Int = 50_000_000

    static func validateImage(
        _ request: ImageUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxImageSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateVideo(
        _ request: VideoUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxVideoSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }

    static func validateDocument(
        _ request: DocumentUploadRequest
    ) throws {

        guard !request.fileName.isEmpty else {
            throw FirebaseStorageServiceError.invalidFileName
        }

        guard !request.data.isEmpty else {
            throw FirebaseStorageServiceError.invalidData
        }

        guard request.data.count <= maxDocumentSize else {
            throw FirebaseStorageServiceError.fileTooLarge
        }
    }
}

// MARK: - Service

final class FirebaseStorageService:
    FirebaseStorageServiceProtocol {
    
    private let storage: Storage
    
    init(
        storage: Storage = .storage()
    ) {
        self.storage = storage
    }
}

// MARK: - Upload Image

func uploadImage(
    request: ImageUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateImage(request)

    let path = StoragePathBuilder.imagePath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Video

func uploadVideo(
    request: VideoUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateVideo(request)

    let path = StoragePathBuilder.videoPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Upload Document

func uploadDocument(
    request: DocumentUploadRequest,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    try StorageValidator.validateDocument(request)

    let path = StoragePathBuilder.documentPath(
        folder: request.folder,
        fileName: request.fileName
    )

    let metadata = StorageMetadataBuilder.make(
        contentType: request.contentType,
        metadata: request.metadata
    )

    return try await upload(
        data: request.data,
        path: path,
        metadata: metadata,
        progress: progress
    )
}

// MARK: - Delete

func deleteFile(
    path: String
) async throws {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    try await reference.delete()
}

// MARK: - Download URL

func downloadURL(
    path: String
) async throws -> URL {

    guard !path.isEmpty else {
        throw FirebaseStorageServiceError.invalidPath
    }

    let reference = storage.reference(
        withPath: path
    )

    return try await reference.downloadURL()
}

// MARK: - Private Upload

private func upload(
    data: Data,
    path: String,
    metadata: StorageMetadata,
    progress: FirebaseUploadProgressHandler?
) async throws -> UploadResult {

    let reference = storage.reference(
        withPath: path
    )

    return try await withCheckedThrowingContinuation {
        continuation in

        let task = reference.putData(
            data,
            metadata: metadata
        )

        task.observe(.progress) {
            snapshot in

            guard
                let value = snapshot.progress
            else {
                return
            }

            let percent =
                Double(value.completedUnitCount)
                / Double(value.totalUnitCount)

            progress?(percent)
        }

        task.observe(.success) { _ in

            Task {

                do {

                    let url =
                        try await reference.downloadURL()

                    let result = UploadResult(
                        path: path,
                        fileName: reference.name,
                        downloadURL: url,
                        contentType:
                            metadata.contentType ?? "",
                        uploadedAt: Date()
                    )

                    continuation.resume(
                        returning: result
                    )

                } catch {

                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }

        task.observe(.failure) {
            snapshot in

            if let error = snapshot.error {

                continuation.resume(
                    throwing: error
                )

                return
            }

            continuation.resume(
                throwing:
                    FirebaseStorageServiceError
                    .uploadFailed
            )
        }
    }
}
}

// MARK: - Avatar Upload

extension FirebaseStorageService {

func uploadAvatar(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + ".jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadAvatarThumbnail(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_thumb.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "users/\(userId)/thumbnail"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadProfileImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_profile.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "profiles/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadBannerImage(
    userId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let fileName =
        UUID().uuidString + "_banner.jpg"

    let request =
        ImageUploadRequest(
            data: data,
            fileName: fileName,
            folder: "banners/\(userId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}
}

// MARK: - Debate Upload

extension FirebaseStorageService {

func uploadDebateThumbnail(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateCover(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        ImageUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + "_cover.jpg",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadImage(
        request: request,
        progress: progress
    )
}

func uploadDebateAttachment(
    debateId: String,
    data: Data,
    fileName: String,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        DocumentUploadRequest(
            data: data,
            fileName: fileName,
            folder: "debates/\(debateId)",
            contentType:
                "application/octet-stream"
        )

    return try await uploadDocument(
        request: request,
        progress: progress
    )
}

func uploadDebateVideo(
    debateId: String,
    data: Data,
    progress: FirebaseUploadProgressHandler? = nil
) async throws -> UploadResult {

    let request =
        VideoUploadRequest(
            data: data,
            fileName:
                UUID().uuidString + ".mp4",
            folder:
                "debates/\(debateId)"
        )

    return try await uploadVideo(
        request: request,
        progress: progress
    )
}
}

// MARK: - Retry Configuration

struct StorageRetryConfiguration {

    let maxRetryCount: Int

    let delay: TimeInterval

    static let `default` =
        StorageRetryConfiguration(
            maxRetryCount: 3,
            delay: 1.0
        )
}

// MARK: - Retry Helper

enum StorageRetryHelper {

    static func execute<T>(
        configuration: StorageRetryConfiguration = .default,
        operation: @escaping () async throws -> T
    ) async throws -> T {

        var currentAttempt = 0

        while true {

            do {

                return try await operation()

            } catch {

                currentAttempt += 1

                if currentAttempt >
                    configuration.maxRetryCount {

                    throw error
                }

                let nanoseconds =
                    UInt64(
                        configuration.delay
                        * 1_000_000_000
                    )

                try await Task.sleep(
                    nanoseconds: nanoseconds
                )
            }
        }
    }
}

// MARK: - Upload Category

enum UploadCategory: String {

    case avatar
    case banner
    case debateImage
    case debateVideo
    case attachment
    case document
    case unknown
}

// MARK: - Analytics Event

struct StorageAnalyticsEvent {

    let category: UploadCategory

    let fileName: String

    let fileSize: Int

    let createdAt: Date
}

// MARK: - Analytics Logger

protocol StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    )
}

// MARK: - Default Analytics Logger

final class DefaultStorageAnalyticsLogger:
    StorageAnalyticsLogger {

    func log(
        event: StorageAnalyticsEvent
    ) {

        print(
            """
            [Storage]
            category: \(event.category.rawValue)
            fileName: \(event.fileName)
            fileSize: \(event.fileSize)
            """
        )
    }
}

// MARK: - Upload Context

struct UploadContext {

    let userId: String?

    let debateId: String?

    let category: UploadCategory

    init(
        userId: String? = nil,
        debateId: String? = nil,
        category: UploadCategory
    ) {

        self.userId = userId
        self.debateId = debateId
        self.category = category
    }
}

// MARK: - Filename Generator

enum StorageFileNameGenerator {

    static func image() -> String {
        UUID().uuidString + ".jpg"
    }

    static func png() -> String {
        UUID().uuidString + ".png"
    }

    static func video() -> String {
        UUID().uuidString + ".mp4"
    }

    static func pdf() -> String {
        UUID().uuidString + ".pdf"
    }

    static func attachment(
        name: String
    ) -> String {

        "\(UUID().uuidString)_\(name)"
    }
}

// MARK: - Path Constants

enum StorageFolder {

    static let users =
        "users"

    static let debates =
        "debates"

    static let documents =
        "documents"

    static let attachments =
        "attachments"

    static let videos =
        "videos"

    static let images =
        "images"
}

// MARK: - Mock Service

final class MockFirebaseStorageService:
    FirebaseStorageServiceProtocol {

    func uploadImage(
        request: ImageUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-image"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadVideo(
        request: VideoUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-video"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func uploadDocument(
        request: DocumentUploadRequest,
        progress: FirebaseUploadProgressHandler?
    ) async throws -> UploadResult {

        progress?(1.0)

        return UploadResult(
            path: request.folder,
            fileName: request.fileName,
            downloadURL:
                URL(
                    string:
                        "https://example.com/mock-document"
                )!,
            contentType:
                request.contentType,
            uploadedAt:
                Date()
        )
    }

    func deleteFile(
        path: String
    ) async throws {

    }

    func downloadURL(
        path: String
    ) async throws -> URL {

        URL(
            string:
                "https://example.com/download"
        )!
    }
}
