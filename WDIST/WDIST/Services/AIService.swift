import Foundation

actor AIService {
    private let keychain = KeychainStore(service: "com.hyphen.own.WDIST")
    private let gemini = GeminiService()
    private let openAI = OpenAIService()

    func summarizeScreenshot(ocrText: String, imageData: Data) async throws -> AIAnalysis {
        switch selectedProvider {
        case .gemini: try await gemini.summarizeScreenshot(ocrText: ocrText, imageData: imageData)
        case .openAI: try await openAI.summarizeScreenshot(ocrText: ocrText, imageData: imageData)
        }
    }

    func generateTags(for ocrText: String) async throws -> [String] {
        switch selectedProvider {
        case .gemini: try await gemini.generateTags(for: ocrText)
        case .openAI: try await openAI.generateTags(for: ocrText)
        }
    }

    func semanticSearch(query: String, candidates: [SearchCandidate]) -> [String: Double] {
        Dictionary(uniqueKeysWithValues: candidates.map { ($0.id, SearchScorer.score(query: query, candidate: $0)) })
    }

    private var selectedProvider: AIProvider {
        guard let rawValue = keychain.value(for: "ai-provider"), let provider = AIProvider(rawValue: rawValue) else { return .gemini }
        return provider
    }
}
