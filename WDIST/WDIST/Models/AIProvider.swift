import Foundation

nonisolated enum AIProvider: String, CaseIterable, Codable, Identifiable, Sendable {
    case gemini
    case openAI

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gemini: "Gemini"
        case .openAI: "OpenAI"
        }
    }

    var keychainAccount: String { "\(rawValue)-api-key" }

    var keyPlaceholder: String {
        switch self {
        case .gemini: "Paste your Gemini API key"
        case .openAI: "Paste your OpenAI API key"
        }
    }
}
