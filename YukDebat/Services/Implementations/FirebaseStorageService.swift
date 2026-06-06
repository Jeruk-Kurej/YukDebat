

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
            
            
            
            
            
