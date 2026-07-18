import Foundation

nonisolated enum AppError: LocalizedError, Equatable, Sendable {
    case photoAccessDenied
    case photoAccessLimited
    case imageUnavailable
    case ocrFailed
    case networkUnavailable
    case invalidAPIKey
    case aiService(String)
    case corruptedImage
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .photoAccessDenied: "Photo Library access is needed to index your screenshots."
        case .photoAccessLimited: "Allow access to more photos to search your complete screenshot library."
        case .imageUnavailable: "This screenshot is no longer available in Photos."
        case .ocrFailed: "We couldn't read text from this screenshot."
        case .networkUnavailable: "You're offline. Your existing index is still searchable."
        case .invalidAPIKey: "Your selected AI provider key isn't valid. Check it in Settings."
        case .aiService(let message): message
        case .corruptedImage: "This screenshot couldn't be processed."
        case .unknown(let message): message
        }
    }
}
